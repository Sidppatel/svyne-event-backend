CREATE OR REPLACE FUNCTION sp_unlink_google(
    p_users_id uuid
) RETURNS SETOF users LANGUAGE plpgsql SECURITY DEFINER
    SET search_path = public, extensions, pg_catalog
AS $$
DECLARE
    v_password_hash text;
    v_google_subject text;
BEGIN
    SELECT password_hash, google_subject
      INTO v_password_hash, v_google_subject
      FROM users
      WHERE users_id = p_users_id;

    IF v_google_subject IS NULL THEN
        RAISE EXCEPTION 'No Google account is linked'
            USING ERRCODE = 'P0002';
    END IF;

    IF v_password_hash IS NULL THEN
        RAISE EXCEPTION 'Set a password before unlinking Google to avoid lockout'
            USING ERRCODE = 'P0002';
    END IF;

    UPDATE users
    SET google_subject = NULL,
        updated_at = now()
    WHERE users_id = p_users_id;

    RETURN QUERY SELECT * FROM users WHERE users_id = p_users_id;
END; $$;
