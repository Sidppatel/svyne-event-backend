CREATE OR REPLACE FUNCTION sp_check_in_booking(
    p_booking_id uuid,
    p_event_id uuid,
    p_staff_user_id uuid
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
        RETURN QUERY SELECT false, 'Booking not found'::text, NULL::text, NULL::text, NULL::text, NULL::text, NULL::timestamptz;
        RETURN;
    END IF;

    IF v_event_id <> p_event_id THEN
        RETURN QUERY SELECT false, 'Booking is for a different event'::text, NULL::text, NULL::text, NULL::text, NULL::text, NULL::timestamptz;
        RETURN;
    END IF;

    IF v_booking_status = 'CheckedIn' THEN
        RETURN QUERY SELECT
            false, 'Booking already checked in'::text,
            v_booking_number, v_user_name, v_event_title,
            'CheckedIn'::text, v_updated_at;
        RETURN;
    END IF;

    IF v_booking_status <> 'Paid' THEN
        RETURN QUERY SELECT
            false,
            ('Booking is ' || v_booking_status || ' — cannot check in')::text,
            v_booking_number, v_user_name, v_event_title,
            v_booking_status::text, NULL::timestamptz;
        RETURN;
    END IF;

    -- Update booking status
    UPDATE bookings
       SET status = 'CheckedIn', updated_at = now()
     WHERE bookings_id = p_booking_id;

    -- Log each ticket check-in and update ticket status
    INSERT INTO checkin_logs (checkin_logs_id, event_id, staff_user_id, booking_id, ticket_id, timestamp, created_at, updated_at)
    SELECT gen_random_uuid(), p_event_id, p_staff_user_id, p_booking_id, t.tickets_id, now(), now(), now()
    FROM tickets t
    WHERE t.bookings_id = p_booking_id AND t.status <> 'CheckedIn';

    UPDATE tickets
       SET status = 'CheckedIn', updated_at = now()
     WHERE bookings_id = p_booking_id AND status <> 'CheckedIn';

    RETURN QUERY SELECT
        true, 'Booking check-in successful'::text,
        v_booking_number, v_user_name, v_event_title,
        'CheckedIn'::text, now();
END;
$$;
