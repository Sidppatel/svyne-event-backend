CREATE OR REPLACE FUNCTION sp_invite_ticket(
    p_ticket_id uuid, p_invite_hash text, p_email text, p_expires_at timestamptz
) RETURNS void LANGUAGE plpgsql
    SET search_path = public, extensions, pg_catalog
AS $$
BEGIN
    UPDATE booking_lines SET
        invite_token_hash = p_invite_hash, invited_email = p_email,
        invite_sent_at = now(), invite_expires_at = p_expires_at,
        status = 'Invited', updated_at = now()
    WHERE booking_lines_id = p_ticket_id AND kind = 'Ticket';
END; $$;