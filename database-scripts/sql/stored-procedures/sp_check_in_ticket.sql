DROP FUNCTION IF EXISTS sp_check_in_ticket(uuid, uuid, uuid);

CREATE OR REPLACE FUNCTION sp_check_in_ticket(
    p_ticket_id uuid,
    p_event_id uuid,
    p_staff_user_id uuid,
    p_method text DEFAULT 'qr_scan'
)
RETURNS TABLE(
    success boolean,
    message text,
    booking_number text,
    guest_name text,
    event_title text,
    status_str text,
    checked_in_at timestamptz
) LANGUAGE plpgsql
    SET search_path = public, extensions, pg_catalog
AS $$
DECLARE
    v_ticket_id uuid;
    v_booking_id uuid;
    v_ticket_status text;
    v_seat_number int;
    v_ticket_updated_at timestamptz;
    v_guest_user_id uuid;
    v_buyer_user_id uuid;
    v_booking_number text;
    v_booking_status text;
    v_event_title text;
    v_guest_name text;
    v_event_id uuid;
    v_all_checked boolean;
BEGIN
    SELECT t.booking_lines_id, t.bookings_id, t.status::text, t.seat_number, t.guest_users_id, t.updated_at, t.events_id
      INTO v_ticket_id, v_booking_id, v_ticket_status, v_seat_number, v_guest_user_id, v_ticket_updated_at, v_event_id
    FROM booking_lines t
    WHERE t.booking_lines_id = p_ticket_id AND t.kind = 'Ticket'
    FOR UPDATE;

    IF NOT FOUND THEN
        PERFORM sp_log_checkin_attempt(p_event_id, p_staff_user_id, NULL, NULL, p_method, 'failed', 'invalid_ticket');
        RETURN;
    END IF;

    IF v_event_id <> p_event_id THEN
        PERFORM sp_log_checkin_attempt(p_event_id, p_staff_user_id, v_booking_id, v_ticket_id, p_method, 'failed', 'wrong_event');
        RETURN QUERY SELECT
            false, 'Ticket is for a different event'::text,
            NULL::text, NULL::text, NULL::text, NULL::text, NULL::timestamptz;
        RETURN;
    END IF;

    SELECT p.booking_number, p.status, p.users_id, e.title
      INTO v_booking_number, v_booking_status, v_buyer_user_id, v_event_title
    FROM bookings p
    JOIN events e ON e.events_id = p.events_id
    WHERE p.bookings_id = v_booking_id
    FOR UPDATE OF p;

    IF v_guest_user_id IS NOT NULL THEN
        SELECT u.first_name || ' ' || u.last_name INTO v_guest_name
        FROM users u WHERE u.users_id = v_guest_user_id;
    ELSE
        SELECT u.first_name || ' ' || u.last_name INTO v_guest_name
        FROM users u WHERE u.users_id = v_buyer_user_id;
    END IF;

    IF v_ticket_status = 'CheckedIn' THEN
        PERFORM sp_log_checkin_attempt(p_event_id, p_staff_user_id, v_booking_id, v_ticket_id, p_method, 'failed', 'already_checked_in');
        RETURN QUERY SELECT
            false,
            ('Ticket already checked in (Seat #' || v_seat_number || ')')::text,
            v_booking_number, v_guest_name, v_event_title,
            'CheckedIn'::text, v_ticket_updated_at;
        RETURN;
    END IF;

    IF v_booking_status NOT IN ('Paid', 'CheckedIn') THEN
        PERFORM sp_log_checkin_attempt(p_event_id, p_staff_user_id, v_booking_id, v_ticket_id, p_method, 'failed', 'booking_not_paid');
        RETURN QUERY SELECT
            false,
            ('Booking is ' || v_booking_status || ' — cannot check in')::text,
            v_booking_number, v_guest_name, v_event_title,
            v_booking_status::text, NULL::timestamptz;
        RETURN;
    END IF;

    IF v_ticket_status <> 'Claimed' AND v_ticket_status <> 'Unassigned' THEN
        PERFORM sp_log_checkin_attempt(p_event_id, p_staff_user_id, v_booking_id, v_ticket_id, p_method, 'failed', 'ticket_not_claimed');
        RETURN QUERY SELECT
            false,
            CASE WHEN v_ticket_status = 'Invited'
                THEN 'Ticket invite not yet accepted — recipient must claim it first'
                ELSE 'Ticket has not been claimed yet — assign it to an attendee first'
            END::text,
            v_booking_number, v_guest_name, v_event_title,
            v_ticket_status::text, NULL::timestamptz;
        RETURN;
    END IF;

    UPDATE booking_lines
       SET status = 'CheckedIn', updated_at = now()
     WHERE booking_lines_id = v_ticket_id;

    PERFORM sp_log_checkin_attempt(p_event_id, p_staff_user_id, v_booking_id, v_ticket_id, p_method, 'success', NULL);

    SELECT NOT EXISTS (
        SELECT 1 FROM booking_lines
         WHERE bookings_id = v_booking_id AND kind = 'Ticket' AND status <> 'CheckedIn'
    ) INTO v_all_checked;

    IF v_all_checked THEN
        UPDATE bookings
           SET status = 'CheckedIn', updated_at = now()
         WHERE bookings_id = v_booking_id;
    END IF;

    RETURN QUERY SELECT
        true,
        ('Check-in successful — Seat #' || v_seat_number)::text,
        v_booking_number, v_guest_name, v_event_title,
        'CheckedIn'::text, now();
END;
$$;
