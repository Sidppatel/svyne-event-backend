CREATE OR REPLACE FUNCTION sp_set_ticket_invite(
    p_ticket_id uuid, p_invite_hash text, p_email text, p_expires_at timestamptz
) RETURNS boolean LANGUAGE plpgsql
    SET search_path = public, extensions, pg_catalog
AS $$
DECLARE v_updated int;
BEGIN
    UPDATE booking_lines SET
        invite_token_hash = p_invite_hash,
        invited_email = p_email,
        invite_sent_at = now(),
        invite_expires_at = p_expires_at,
        status = 'Invited',
        guest_users_id = NULL,
        claimed_at = NULL,
        updated_at = now()
    WHERE booking_lines_id = p_ticket_id AND kind = 'Ticket'
      AND status IN ('Unassigned', 'Invited');
    GET DIAGNOSTICS v_updated = ROW_COUNT;
    RETURN v_updated > 0;
END; $$;
