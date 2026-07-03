DROP FUNCTION IF EXISTS sp_check_in_booking(uuid, uuid, uuid);

CREATE OR REPLACE FUNCTION sp_check_in_booking(
    p_booking_id uuid,
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
    v_booking_number text;
    v_booking_status text;
    v_updated_at timestamptz;
    v_event_title text;
    v_user_name text;
    v_event_id uuid;
    v_checked_count int;
BEGIN
    SELECT p.booking_number, p.status, p.updated_at,
           e.title, u.first_name || ' ' || u.last_name, p.events_id
      INTO v_booking_number, v_booking_status, v_updated_at,
           v_event_title, v_user_name, v_event_id
    FROM bookings p
    JOIN events e ON e.events_id = p.events_id
    JOIN users u ON u.users_id = p.users_id
    WHERE p.bookings_id = p_booking_id
    FOR UPDATE OF p;

    IF NOT FOUND THEN
        PERFORM sp_log_checkin_attempt(p_event_id, p_staff_user_id, NULL, NULL, p_method, 'failed', 'booking_not_found');
        RETURN QUERY SELECT false, 'Booking not found'::text, NULL::text, NULL::text, NULL::text, NULL::text, NULL::timestamptz;
        RETURN;
    END IF;

    IF v_event_id <> p_event_id THEN
        PERFORM sp_log_checkin_attempt(p_event_id, p_staff_user_id, p_booking_id, NULL, p_method, 'failed', 'wrong_event');
        RETURN QUERY SELECT false, 'Booking is for a different event'::text, NULL::text, NULL::text, NULL::text, NULL::text, NULL::timestamptz;
        RETURN;
    END IF;

    IF v_booking_status = 'CheckedIn' THEN
        PERFORM sp_log_checkin_attempt(p_event_id, p_staff_user_id, p_booking_id, NULL, p_method, 'failed', 'already_checked_in');
        RETURN QUERY SELECT
            false, 'Booking already checked in'::text,
            v_booking_number, v_user_name, v_event_title,
            'CheckedIn'::text, v_updated_at;
        RETURN;
    END IF;

    IF v_booking_status <> 'Paid' THEN
        PERFORM sp_log_checkin_attempt(p_event_id, p_staff_user_id, p_booking_id, NULL, p_method, 'failed', 'booking_not_paid');
        RETURN QUERY SELECT
            false,
            ('Booking is ' || v_booking_status || ' — cannot check in')::text,
            v_booking_number, v_user_name, v_event_title,
            v_booking_status::text, NULL::timestamptz;
        RETURN;
    END IF;

    UPDATE bookings
       SET status = 'CheckedIn', updated_at = now()
     WHERE bookings_id = p_booking_id;

    INSERT INTO checkin_logs (checkin_logs_id, event_id, staff_user_id, booking_id, ticket_id,
        timestamp, method, status, failure_reason, created_at, updated_at)
    SELECT gen_random_uuid(), p_event_id, p_staff_user_id, p_booking_id, t.booking_lines_id,
        now(), p_method, 'success', NULL, now(), now()
    FROM booking_lines t
    WHERE t.bookings_id = p_booking_id AND t.kind = 'Ticket' AND t.status <> 'CheckedIn';

    GET DIAGNOSTICS v_checked_count = ROW_COUNT;

    UPDATE booking_lines
       SET status = 'CheckedIn', updated_at = now()
     WHERE bookings_id = p_booking_id AND kind = 'Ticket' AND status <> 'CheckedIn';

    RETURN QUERY SELECT
        true,
        ('Checked in ' || v_checked_count || ' tickets for booking ' || v_booking_number)::text,
        v_booking_number, v_user_name, v_event_title,
        'CheckedIn'::text, now();
END;
$$;
