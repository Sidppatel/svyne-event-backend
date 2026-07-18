DROP FUNCTION IF EXISTS sp_reprice_booking_for_method(uuid, uuid, text);

CREATE OR REPLACE FUNCTION sp_reprice_booking_for_method(
    p_booking_id uuid, p_user_id uuid, p_method text
) RETURNS TABLE(
    subtotal_cents int,
    fee_cents int,
    total_cents int,
    baseline_total_cents int,
    tax_cents int
) LANGUAGE plpgsql
    SET search_path = public, extensions, pg_catalog
AS $$
DECLARE
    v_status text; v_owner uuid; v_hold timestamptz;
    v_tenant uuid; v_event uuid;
    v_ach_ok boolean;
    v_line record;
    v_platform int; v_gateway int;
    v_card_platform int; v_card_gateway int;
    v_sub int := 0; v_fee int := 0; v_total int := 0; v_baseline int := 0;
    v_tax_rate numeric; v_tax int := 0; v_baseline_tax int := 0;
BEGIN
    IF p_method NOT IN ('card', 'ach') THEN
        RAISE EXCEPTION 'Unknown payment method %', p_method USING ERRCODE = '22023';
    END IF;

    SELECT b.status, b.users_id, b.hold_expires_at, b.tenants_id, b.events_id
      INTO v_status, v_owner, v_hold, v_tenant, v_event
      FROM bookings b
     WHERE b.bookings_id = p_booking_id
     FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Booking not found' USING ERRCODE = 'P0002';
    END IF;
    IF v_owner <> p_user_id THEN
        RAISE EXCEPTION 'Booking does not belong to caller' USING ERRCODE = '42501';
    END IF;
    IF v_status <> 'Pending' THEN
        RAISE EXCEPTION 'Booking is not payable (status %)', v_status USING ERRCODE = '22023';
    END IF;
    IF v_hold IS NOT NULL AND v_hold <= now() THEN
        RAISE EXCEPTION 'Booking hold has expired' USING ERRCODE = '22023';
    END IF;

    SELECT t.ach_enabled AND e.ach_enabled
      INTO v_ach_ok
      FROM tenants t JOIN events e ON e.events_id = v_event
     WHERE t.tenants_id = v_tenant;

    IF p_method = 'ach' AND COALESCE(v_ach_ok, false) = false THEN
        RAISE EXCEPTION 'ACH is not available for this event' USING ERRCODE = '22023';
    END IF;

    FOR v_line IN
        SELECT bl.booking_lines_id, bl.selling_price_cents
          FROM booking_lines bl
         WHERE bl.bookings_id = p_booking_id
           AND bl.selling_price_cents > 0
    LOOP
        UPDATE booking_lines
           SET platform_fee_cents = 0,
               gateway_fee_cents = 0,
               fee_cents = 0,
               total_cents = selling_price_cents,
               final_price_cents = selling_price_cents,
               updated_at = now()
         WHERE booking_lines_id = v_line.booking_lines_id;

        v_sub := v_sub + v_line.selling_price_cents;
    END LOOP;

    SELECT ofees.platform_fee_cents, ofees.gateway_fee_cents
      INTO v_card_platform, v_card_gateway
      FROM app.order_fees(v_event, v_sub, 'card') ofees;
    SELECT ofees.platform_fee_cents, ofees.gateway_fee_cents
      INTO v_platform, v_gateway
      FROM app.order_fees(v_event, v_sub, p_method) ofees;

    v_fee := v_platform + v_gateway;
    v_total := v_sub + v_fee;
    v_baseline := v_sub + v_card_platform + v_card_gateway;

    SELECT bt.combined_rate INTO v_tax_rate
      FROM booking_taxes bt
     WHERE bt.bookings_id = p_booking_id;
    IF COALESCE(v_tax_rate, 0) > 0 AND v_sub > 0 THEN
        v_tax := round((v_sub + v_fee) * v_tax_rate)::int;
        v_baseline_tax := round(v_baseline * v_tax_rate)::int;
        UPDATE booking_taxes
           SET taxable_amount_cents = v_sub + v_fee,
               tax_amount_cents = v_tax,
               calculated_at = now(),
               updated_at = now()
         WHERE bookings_id = p_booking_id;
    END IF;
    v_fee := v_fee + v_tax;
    v_total := v_total + v_tax;
    v_baseline := v_baseline + v_baseline_tax;

    UPDATE bookings
       SET subtotal_cents = v_sub, fee_cents = v_fee, total_cents = v_total,
           tax_cents = v_tax, updated_at = now()
     WHERE bookings_id = p_booking_id;

    subtotal_cents := v_sub;
    fee_cents := v_fee;
    total_cents := v_total;
    baseline_total_cents := v_baseline;
    tax_cents := v_tax;
    RETURN NEXT;
END; $$;
