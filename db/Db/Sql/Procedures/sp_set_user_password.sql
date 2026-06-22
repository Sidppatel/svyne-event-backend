CREATE OR REPLACE FUNCTION sp_set_user_password(
    p_user_id uuid,
    p_new_password_hash text,
    p_revoke_other_sessions boolean DEFAULT true,
    p_current_session_hash text DEFAULT NULL
) RETURNS void LANGUAGE plpgsql
    SET search_path = public, extensions, pg_catalog
AS $$
BEGIN
    UPDATE users
    SET "PasswordHash" = p_new_password_hash,
        "UpdatedAt" = now()
    WHERE "Id" = p_user_id;

    IF p_revoke_other_sessions THEN
        UPDATE device_sessions
        SET "RevokedAt" = now(),
            "UpdatedAt" = now()
        WHERE "UserId" = p_user_id
          AND "RevokedAt" IS NULL
          AND (p_current_session_hash IS NULL OR "SessionHash" <> p_current_session_hash);
    END IF;
END; $$;
