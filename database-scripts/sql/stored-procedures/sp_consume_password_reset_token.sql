CREATE OR REPLACE FUNCTION sp_consume_password_reset_token(
    p_token_hash text
) RETURNS SETOF users LANGUAGE plpgsql SECURITY DEFINER
    SET search_path = public, extensions, pg_catalog
AS $$
DECLARE
    v_users_id uuid;
BEGIN
    SELECT users_id INTO v_users_id
    FROM password_reset_tokens
    WHERE token_hash = p_token_hash
      AND is_used = false
      AND expires_at > now()
    LIMIT 1;

    -- Already used / expired / unknown: return no rows so the caller surfaces a
    -- clean "Invalid or expired token" instead of a 500. Enforces single use.
    IF v_users_id IS NULL THEN
        RETURN;
    END IF;

    UPDATE password_reset_tokens
    SET is_used = true, used_at = now(), updated_at = now()
    WHERE token_hash = p_token_hash;

    RETURN QUERY SELECT * FROM users WHERE users_id = v_users_id;
END; $$;
