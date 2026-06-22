CREATE OR REPLACE FUNCTION sp_signin_user_google(
    p_google_subject text,
    p_email text,
    p_email_hash text,
    p_first_name text,
    p_last_name text
) RETURNS SETOF users LANGUAGE plpgsql
    SET search_path = public, extensions, pg_catalog
AS $$
DECLARE
    v_id uuid;
    v_existing_password_hash text;
    v_existing_google_subject text;
BEGIN
    SELECT "Id" INTO v_id FROM users WHERE "GoogleSubject" = p_google_subject;

    IF v_id IS NOT NULL THEN
        UPDATE users
        SET "LastLoginAt" = now(),
            "UpdatedAt" = now()
        WHERE "Id" = v_id;
        RETURN QUERY SELECT * FROM users WHERE "Id" = v_id;
        RETURN;
    END IF;

    SELECT "Id", "PasswordHash", "GoogleSubject"
      INTO v_id, v_existing_password_hash, v_existing_google_subject
      FROM users WHERE "EmailHash" = p_email_hash;

    IF v_id IS NULL THEN
        INSERT INTO users (
            "Email", "EmailHash", "FirstName", "LastName",
            "PasswordHash", "EmailVerified", "EmailVerifiedAt",
            "IsActive", "LastLoginAt",
            "OptInLocationEmail", "HasCompletedOnboarding",
            "GoogleSubject", "CreatedAt", "UpdatedAt"
        ) VALUES (
            p_email, p_email_hash, p_first_name, p_last_name,
            NULL, true, now(),
            true, now(),
            false, false,
            p_google_subject, now(), now()
        )
        RETURNING "Id" INTO v_id;
        RETURN QUERY SELECT * FROM users WHERE "Id" = v_id;
        RETURN;
    END IF;

    IF v_existing_google_subject IS NOT NULL AND v_existing_google_subject <> p_google_subject THEN
        RAISE EXCEPTION 'Google account already linked to a different identity'
            USING ERRCODE = 'P0001';
    END IF;

    IF v_existing_password_hash IS NOT NULL AND v_existing_google_subject IS NULL THEN
        RAISE EXCEPTION 'Existing password account requires password sign-in to link Google'
            USING ERRCODE = 'P0002';
    END IF;

    UPDATE users
    SET "GoogleSubject" = p_google_subject,
        "EmailVerified" = true,
        "EmailVerifiedAt" = COALESCE("EmailVerifiedAt", now()),
        "LastLoginAt" = now(),
        "UpdatedAt" = now()
    WHERE "Id" = v_id;

    RETURN QUERY SELECT * FROM users WHERE "Id" = v_id;
END;
$$;
