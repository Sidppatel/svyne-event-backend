CREATE OR REPLACE FUNCTION sp_check_in_ticket_by_token(
    p_qr_token text,
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
    v_ticket_id uuid;
BEGIN
    SELECT booking_lines_id INTO v_ticket_id
    FROM booking_lines
    WHERE qr_token = p_qr_token AND kind = 'Ticket';

    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Ticket not found'::text, NULL::text, NULL::text, NULL::text, NULL::text, NULL::timestamptz;
        RETURN;
    END IF;

    RETURN QUERY SELECT * FROM sp_check_in_ticket(v_ticket_id, p_event_id, p_staff_user_id);
END;
$$;
