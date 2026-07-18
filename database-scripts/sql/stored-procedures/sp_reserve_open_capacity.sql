DROP FUNCTION IF EXISTS sp_reserve_open_capacity(uuid, uuid, int, uuid, int, int, int, text);
DROP FUNCTION IF EXISTS sp_reserve_open_capacity(uuid, uuid, int, uuid, int, int, int);

CREATE OR REPLACE FUNCTION sp_reserve_open_capacity(
    p_user_id uuid,
    p_event_id uuid,
    p_seats int,
    p_event_ticket_type_id uuid,
    p_subtotal_cents int,
    p_fee_cents int,
    p_total_cents int
) RETURNS TABLE(bookings_id uuid, booking_number text) LANGUAGE plpgsql
    SET search_path = public, extensions, pg_catalog
AS $$
DECLARE
    v_id uuid;
    v_event_type text;
    v_max_capacity int;
    v_total_reserved int;
    v_tt_max int;
    v_tt_sold int;
    v_tenant uuid;
    v_number text;
    v_attempt int := 0;
    v_hold int;
    v_prices_id uuid;
    v_bd record;
    v_seat_idx int;
    v_code text;
    v_qr text;
    v_tax_rate numeric; v_tax_total int; v_taxable int;
    v_sub int; v_platform_total int; v_gateway_total int;
    v_tzip text; v_tstate text; v_tcounty text; v_tcity text;
    v_tstate_rate numeric; v_tcounty_rate numeric; v_tcity_rate numeric; v_tlocal_rate numeric;
    v_tapi text;
BEGIN
    SELECT COALESCE((SELECT value::int FROM app_settings WHERE key = 'booking_hold_seconds'), 600)
      INTO v_hold;

    SELECT b.bookings_id, b.booking_number INTO v_id, v_number
      FROM bookings b
      JOIN booking_lines bl ON bl.bookings_id = b.bookings_id
      WHERE b.users_id = p_user_id
        AND b.events_id = p_event_id
        AND b.status = 'Pending'
        AND bl.kind = 'Ticket'
        AND bl.event_ticket_types_id IS NOT DISTINCT FROM p_event_ticket_type_id
        AND (b.hold_expires_at IS NULL OR b.hold_expires_at > now())
      ORDER BY b.created_at DESC
      LIMIT 1;

    IF v_id IS NOT NULL THEN
        UPDATE bookings
           SET hold_expires_at = now() + make_interval(secs => v_hold), updated_at = now()
         WHERE bookings.bookings_id = v_id;
        bookings_id := v_id;
        booking_number := v_number;
        RETURN NEXT;
        RETURN;
    END IF;

    SELECT event_type, tenants_id
      INTO v_event_type, v_tenant
      FROM events
      WHERE events_id = p_event_id
      FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Event not found' USING ERRCODE = 'P0002';
    END IF;

    SELECT COALESCE(SUM(capacity), 0)
      INTO v_max_capacity
      FROM event_ticket_types
      WHERE events_id = p_event_id AND is_active = true;
    IF v_event_type NOT IN ('Open', 'Both') THEN
        RAISE EXCEPTION 'Event does not sell open capacity' USING ERRCODE = '22023';
    END IF;

    v_total_reserved := app.event_seats_live(p_event_id);

    IF v_max_capacity IS NOT NULL AND v_max_capacity > 0
       AND v_total_reserved + p_seats > v_max_capacity THEN
        RAISE EXCEPTION 'Not enough capacity. Available: %, requested: %',
            v_max_capacity - v_total_reserved, p_seats USING ERRCODE = '23514';
    END IF;

    IF p_event_ticket_type_id IS NULL THEN
        RAISE EXCEPTION 'Ticket type required' USING ERRCODE = '22023';
    END IF;

    SELECT max_quantity, prices_id
      INTO v_tt_max, v_prices_id
      FROM event_ticket_types
      WHERE event_ticket_types_id = p_event_ticket_type_id
      FOR UPDATE;

    IF v_prices_id IS NULL THEN
        RAISE EXCEPTION 'Ticket type has no linked price' USING ERRCODE = '22023';
    END IF;

    IF v_tt_max IS NOT NULL THEN
        v_tt_sold := app.ticket_type_seats_live(p_event_ticket_type_id);
        IF v_tt_sold + p_seats > v_tt_max THEN
            RAISE EXCEPTION 'Not enough availability for ticket type. Available: %, requested: %',
                v_tt_max - v_tt_sold, p_seats USING ERRCODE = '23514';
        END IF;
    END IF;

    SELECT * INTO v_bd FROM app.price_breakdown(v_prices_id, now(), 1,
                             app.remaining_for_price(v_prices_id));

    v_sub := v_bd.selling_price_cents * p_seats;
    SELECT ofees.platform_fee_cents, ofees.gateway_fee_cents
      INTO v_platform_total, v_gateway_total
      FROM app.order_fees(p_event_id, v_sub, 'card') ofees;

    v_tax_rate := app.event_tax_rate(p_event_id);
    v_taxable := v_sub + v_platform_total + v_gateway_total;
    v_tax_total := CASE WHEN v_taxable > 0 AND COALESCE(v_tax_rate, 0) > 0
                   THEN round(v_taxable * v_tax_rate)::int ELSE 0 END;
    SELECT COALESCE(a.zip_code, ''), trc.state, trc.county, trc.city,
           COALESCE(trc.state_rate, 0), COALESCE(trc.county_rate, 0),
           COALESCE(trc.city_rate, 0), COALESCE(trc.local_rate, 0), trc.api_response_id
      INTO v_tzip, v_tstate, v_tcounty, v_tcity,
           v_tstate_rate, v_tcounty_rate, v_tcity_rate, v_tlocal_rate, v_tapi
      FROM events e
      JOIN venues ve ON ve.venues_id = e.venues_id
      LEFT JOIN addresses a ON a.addresses_id = ve.addresses_id
      LEFT JOIN tax_rate_cache trc ON trc.zip_code = a.zip_code
     WHERE e.events_id = p_event_id;

    LOOP
        v_attempt := v_attempt + 1;
        v_number := 'BK-' || UPPER(SUBSTRING(gen_random_uuid()::text FROM 1 FOR 10));
        BEGIN
            INSERT INTO bookings (tenants_id, booking_number, status, users_id, events_id,
                subtotal_cents, fee_cents, total_cents, seats_reserved,
                tax_cents, tax_rate, tax_state, tax_county, tax_city, tax_calculated_at,
                hold_expires_at, created_at, updated_at)
            VALUES (v_tenant, v_number, 'Pending', p_user_id, p_event_id,
                v_sub,
                v_platform_total + v_gateway_total + v_tax_total,
                v_taxable + v_tax_total, p_seats,
                v_tax_total, v_tax_rate, v_tstate, v_tcounty, v_tcity, now(),
                now() + make_interval(secs => v_hold), now(), now())
            RETURNING bookings.bookings_id INTO v_id;
            EXIT;
        EXCEPTION WHEN unique_violation THEN
            IF v_attempt >= 5 THEN RAISE; END IF;
        END;
    END LOOP;

    INSERT INTO booking_taxes (tenants_id, bookings_id, zip_code, state, county, city,
        combined_rate, state_rate, county_rate, city_rate, local_rate,
        taxable_amount_cents, tax_amount_cents, collected_by, api_response_id, calculated_at, created_at, updated_at)
    VALUES (v_tenant, v_id, COALESCE(v_tzip, ''), v_tstate, v_tcounty, v_tcity,
        COALESCE(v_tax_rate, 0), v_tstate_rate, v_tcounty_rate, v_tcity_rate, v_tlocal_rate,
        v_taxable, v_tax_total, (SELECT t.tax_collection_mode FROM tenants t WHERE t.tenants_id = v_tenant),
        v_tapi, now(), now(), now());

    FOR v_seat_idx IN 1..p_seats LOOP
        v_code := 'TK-' || UPPER(SUBSTRING(gen_random_uuid()::text FROM 1 FOR 8));
        v_qr := encode(gen_random_bytes(32), 'hex');

        INSERT INTO booking_lines (tenants_id, bookings_id, events_id, kind, event_ticket_types_id,
            tables_id, prices_id, seats, ticket_code, qr_token, seat_number, status,
            base_price_cents, selling_price_cents, discount_cents,
            applied_price_rules_id, applied_rule_name,
            platform_fee_cents, gateway_fee_cents,
            subtotal_cents, fee_cents, total_cents, final_price_cents, currency,
            created_at, updated_at)
        VALUES (v_tenant, v_id, p_event_id, 'Ticket', p_event_ticket_type_id,
            NULL, v_prices_id, 1, v_code, v_qr, v_seat_idx, 'Unassigned',
            v_bd.base_price_cents, v_bd.selling_price_cents, v_bd.discount_cents,
            v_bd.applied_price_rules_id, v_bd.applied_rule_name,
            0, 0,
            v_bd.selling_price_cents,
            0,
            v_bd.selling_price_cents, v_bd.selling_price_cents, v_bd.currency,
            now(), now());
    END LOOP;

    bookings_id := v_id;
    booking_number := v_number;
    RETURN NEXT;
END; $$;
