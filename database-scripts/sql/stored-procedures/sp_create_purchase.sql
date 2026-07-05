DROP FUNCTION IF EXISTS sp_create_booking(uuid, uuid, uuid, int, uuid, int, int, int, text, text);
DROP FUNCTION IF EXISTS sp_create_booking(uuid, uuid, uuid, int, uuid, int, int, int, text);

CREATE OR REPLACE FUNCTION sp_create_booking(
    p_user_id uuid, p_event_id uuid, p_table_id uuid, p_seats int,
    p_event_ticket_type_id uuid,
    p_subtotal_cents int, p_fee_cents int, p_total_cents int,
    p_status text DEFAULT 'Pending'
) RETURNS TABLE(bookings_id uuid, booking_number text) LANGUAGE plpgsql
    SET search_path = public, extensions, pg_catalog
AS $$
DECLARE
    v_id uuid; v_tenant uuid; v_number text; v_attempt int := 0; v_hold int; v_tbl_status text;
    v_prices_id uuid; v_kind text; v_seats int := COALESCE(p_seats, 1);
    v_bd record;
    v_seat_idx int;
    v_code text;
    v_qr text;
BEGIN
    SELECT tenants_id INTO v_tenant FROM events WHERE events_id = p_event_id;

    IF p_table_id IS NOT NULL THEN
        v_kind := 'Table';
        SELECT COALESCE(t.capacity_override, et.capacity), et.prices_id
          INTO v_seats, v_prices_id
          FROM tables t JOIN event_tables et ON et.event_tables_id = t.event_tables_id
         WHERE t.tables_id = p_table_id;
        v_seats := GREATEST(COALESCE(v_seats, 1), 1);
    ELSIF p_event_ticket_type_id IS NOT NULL THEN
        v_kind := 'Ticket';
        v_seats := GREATEST(v_seats, 1);
        SELECT prices_id INTO v_prices_id
          FROM event_ticket_types WHERE event_ticket_types_id = p_event_ticket_type_id;
    ELSE
        RAISE EXCEPTION 'Booking requires a table or ticket type' USING ERRCODE = '22023';
    END IF;

    IF v_prices_id IS NULL THEN
        RAISE EXCEPTION 'Sellable has no linked price' USING ERRCODE = '22023';
    END IF;

    SELECT COALESCE((SELECT value::int FROM app_settings WHERE key = 'booking_hold_seconds'), 600)
      INTO v_hold;

    IF p_status = 'Pending' AND p_table_id IS NOT NULL THEN
        SELECT b.bookings_id, b.booking_number INTO v_id, v_number
          FROM bookings b
          JOIN booking_lines bl ON bl.bookings_id = b.bookings_id
          WHERE b.users_id = p_user_id
            AND b.events_id = p_event_id
            AND bl.tables_id = p_table_id
            AND bl.kind = 'Table'
            AND b.status = 'Pending'
            AND (b.hold_expires_at IS NULL OR b.hold_expires_at > now())
          ORDER BY b.created_at DESC
          LIMIT 1;

        IF v_id IS NOT NULL THEN
            UPDATE bookings
               SET hold_expires_at = now() + make_interval(secs => v_hold), updated_at = now()
             WHERE bookings.bookings_id = v_id;
            UPDATE tables
               SET lock_expires_at = now() + make_interval(secs => v_hold), updated_at = now()
             WHERE tables_id = p_table_id;
            bookings_id := v_id;
            booking_number := v_number;
            RETURN NEXT;
            RETURN;
        END IF;
    END IF;

    IF p_table_id IS NOT NULL THEN
        SELECT status INTO v_tbl_status FROM tables WHERE tables_id = p_table_id FOR UPDATE;
        IF v_tbl_status = 'Booked' THEN
            RAISE EXCEPTION 'Table already booked' USING ERRCODE = '23514';
        END IF;
        IF v_tbl_status = 'Locked' THEN
            IF EXISTS (SELECT 1 FROM tables
                       WHERE tables_id = p_table_id
                         AND lock_expires_at IS NOT NULL AND lock_expires_at > now()) THEN
                RAISE EXCEPTION 'Table is currently held by another user' USING ERRCODE = '23514';
            END IF;
        END IF;
    END IF;

    IF v_kind = 'Ticket' THEN
        SELECT * INTO v_bd FROM app.price_breakdown(v_prices_id, now(), 1,
                                 app.remaining_for_price(v_prices_id));
    ELSE
        SELECT * INTO v_bd FROM app.price_breakdown(v_prices_id, now(), v_seats,
                                 app.remaining_for_price(v_prices_id));
    END IF;

    LOOP
        v_attempt := v_attempt + 1;
        v_number := 'BK-' || UPPER(SUBSTRING(gen_random_uuid()::text FROM 1 FOR 10));
        BEGIN
            INSERT INTO bookings (tenants_id, booking_number, status, users_id, events_id,
                subtotal_cents, fee_cents, total_cents, seats_reserved, hold_expires_at, created_at, updated_at)
            VALUES (v_tenant, v_number, p_status, p_user_id, p_event_id,
                CASE WHEN v_kind = 'Ticket' THEN v_bd.selling_price_cents * v_seats ELSE v_bd.selling_price_cents END,
                CASE WHEN v_kind = 'Ticket' THEN (v_bd.platform_fee_cents + v_bd.gateway_fee_cents) * v_seats ELSE (v_bd.platform_fee_cents + v_bd.gateway_fee_cents) END,
                CASE WHEN v_kind = 'Ticket' THEN v_bd.final_price_cents * v_seats ELSE v_bd.final_price_cents END,
                v_seats,
                CASE WHEN p_status = 'Pending' THEN now() + make_interval(secs => v_hold) ELSE NULL END,
                now(), now())
            RETURNING bookings.bookings_id INTO v_id;
            EXIT;
        EXCEPTION WHEN unique_violation THEN
            IF v_attempt >= 5 THEN RAISE; END IF;
        END;
    END LOOP;

    IF v_kind = 'Ticket' THEN
        FOR v_seat_idx IN 1..v_seats LOOP
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
                v_bd.platform_fee_cents, v_bd.gateway_fee_cents,
                v_bd.selling_price_cents,
                v_bd.platform_fee_cents + v_bd.gateway_fee_cents,
                v_bd.final_price_cents, v_bd.final_price_cents, v_bd.currency,
                now(), now());
        END LOOP;
    ELSIF v_kind = 'Table' THEN
        v_code := 'TBL-' || UPPER(SUBSTRING(gen_random_uuid()::text FROM 1 FOR 8));
        v_qr := encode(gen_random_bytes(32), 'hex');

        INSERT INTO booking_lines (tenants_id, bookings_id, events_id, kind, event_ticket_types_id,
            tables_id, prices_id, seats, ticket_code, qr_token, status,
            base_price_cents, selling_price_cents, discount_cents,
            applied_price_rules_id, applied_rule_name,
            platform_fee_cents, gateway_fee_cents,
            subtotal_cents, fee_cents, total_cents, final_price_cents, currency,
            created_at, updated_at)
        VALUES (v_tenant, v_id, p_event_id, 'Table', NULL,
            p_table_id, v_prices_id, v_seats, v_code, v_qr, 'Unassigned',
            v_bd.base_price_cents, v_bd.selling_price_cents, v_bd.discount_cents,
            v_bd.applied_price_rules_id, v_bd.applied_rule_name,
            v_bd.platform_fee_cents, v_bd.gateway_fee_cents,
            v_bd.selling_price_cents,
            v_bd.platform_fee_cents + v_bd.gateway_fee_cents,
            v_bd.final_price_cents, v_bd.final_price_cents, v_bd.currency,
            now(), now());

        IF p_status = 'Pending' THEN
            UPDATE tables
               SET status = 'Locked', locked_by_users_id = p_user_id,
                   lock_expires_at = now() + make_interval(secs => v_hold), updated_at = now()
             WHERE tables_id = p_table_id;
        END IF;
    END IF;

    bookings_id := v_id;
    booking_number := v_number;
    RETURN NEXT;
END; $$;
