CREATE OR REPLACE FUNCTION sp_check_in_booking_by_number(
    p_booking_number text,
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
    v_booking_id uuid;
BEGIN
    SELECT bookings_id INTO v_booking_id
    FROM bookings
    WHERE booking_number = p_booking_number AND events_id = p_event_id;

    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Booking number not found'::text, NULL::text, NULL::text, NULL::text, NULL::text, NULL::timestamptz;
        RETURN;
    END IF;

    RETURN QUERY SELECT * FROM sp_check_in_booking(v_booking_id, p_event_id, p_staff_user_id);
END;
$$;
