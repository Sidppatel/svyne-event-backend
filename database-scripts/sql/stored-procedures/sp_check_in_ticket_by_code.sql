DROP FUNCTION IF EXISTS sp_check_in_ticket_by_code(text, uuid, uuid);

CREATE OR REPLACE FUNCTION sp_check_in_ticket_by_code(
    p_ticket_code text,
    p_event_id uuid,
    p_staff_user_id uuid,
    p_method text DEFAULT 'manual_entry'
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
BEGIN
    SELECT booking_lines_id INTO v_ticket_id
    FROM booking_lines
    WHERE ticket_code = p_ticket_code AND events_id = p_event_id AND kind = 'Ticket';

    IF NOT FOUND THEN
        PERFORM sp_log_checkin_attempt(p_event_id, p_staff_user_id, NULL, NULL, p_method, 'failed', 'invalid_ticket');
        RETURN QUERY SELECT false, 'Ticket code not found'::text, NULL::text, NULL::text, NULL::text, NULL::text, NULL::timestamptz;
        RETURN;
    END IF;

    RETURN QUERY SELECT * FROM sp_check_in_ticket(v_ticket_id, p_event_id, p_staff_user_id, p_method);
END;
$$;
