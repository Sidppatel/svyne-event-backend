



DROP FUNCTION IF EXISTS sp_get_booking_for_payment(uuid, uuid);
CREATE OR REPLACE FUNCTION sp_get_booking_for_payment(
    p_booking_id uuid, p_user_id uuid
) RETURNS TABLE(
    bookings_id uuid,
    status text,
    subtotal_cents int,
    fee_cents int,
    total_cents int,
    currency text,
    tenants_id uuid,
    connected_account_id text,
    charges_enabled boolean,
    existing_intent_id text,
    existing_status text,
    hold_expires_at timestamptz,
    ach_allowed boolean,
    tax_cents int,
    tax_rate numeric,
    venue_zip text,
    venue_city text,
    venue_state text,
    event_name text,
    ticket_count int,
    tenant_name text,
    event_date timestamptz,
    tax_state_cents int,
    tax_county_cents int,
    tax_city_cents int,
    tax_local_cents int,
    tax_jurisdiction text
) LANGUAGE plpgsql
    SET search_path = public, extensions, pg_catalog
AS $$
DECLARE v_status text; v_owner uuid; v_hold timestamptz;
BEGIN
    SELECT b.status, b.users_id, b.hold_expires_at
      INTO v_status, v_owner, v_hold
      FROM bookings b
      WHERE b.bookings_id = p_booking_id
      FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Booking not found' USING ERRCODE = 'P0002';
    END IF;
    IF v_owner <> p_user_id THEN
        RAISE EXCEPTION 'Booking does not belong to caller' USING ERRCODE = '42501';
    END IF;
    IF v_status NOT IN ('Pending') THEN
        RAISE EXCEPTION 'Booking is not payable (status %)', v_status USING ERRCODE = '22023';
    END IF;
    IF v_hold IS NOT NULL AND v_hold <= now() THEN
        RAISE EXCEPTION 'Booking hold has expired' USING ERRCODE = '22023';
    END IF;

    RETURN QUERY
    SELECT b.bookings_id,
           b.status::text,
           b.subtotal_cents,
           b.fee_cents,
           b.total_cents,
           'usd'::text,
           b.tenants_id,
           t.stripe_connected_account_id::text,
           t.stripe_charges_enabled,
           st.payment_intent_id::text,
           st.status::text,
           b.hold_expires_at,
           (t.ach_enabled AND e.ach_enabled),
           b.tax_cents,
           b.tax_rate,
           COALESCE(a.zip_code, '')::text,
           COALESCE(a.city, '')::text,
           COALESCE(a.state, '')::text,
           e.title::text,
           COALESCE(b.seats_reserved, 1),
           t.name::text,
           e.start_date,
           round(bt.taxable_amount_cents * bt.state_rate)::int,
           round(bt.taxable_amount_cents * bt.county_rate)::int,
           round(bt.taxable_amount_cents * bt.city_rate)::int,
           round(bt.taxable_amount_cents * bt.local_rate)::int,
           NULLIF(concat_ws('-', bt.state, bt.county, bt.city), '')::text
      FROM bookings b
      JOIN tenants t ON t.tenants_id = b.tenants_id
      JOIN events e ON e.events_id = b.events_id
      LEFT JOIN venues ve ON ve.venues_id = e.venues_id
      LEFT JOIN addresses a ON a.addresses_id = ve.addresses_id
      LEFT JOIN stripe_transactions st ON st.bookings_id = b.bookings_id
      LEFT JOIN booking_taxes bt ON bt.bookings_id = b.bookings_id
     WHERE b.bookings_id = p_booking_id;
END; $$;
