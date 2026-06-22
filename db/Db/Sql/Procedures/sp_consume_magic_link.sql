CREATE OR REPLACE FUNCTION sp_consume_magic_link(p_token_hash text)
RETURNS TABLE (
    "Id" uuid, "Email" text, "ExpiresAt" timestamptz
) LANGUAGE plpgsql
    SET search_path = public, extensions, pg_catalog
AS $$
DECLARE
    v_email text;
BEGIN
    UPDATE magic_link_tokens AS t
    SET "IsUsed" = true, "UsedAt" = now(), "UpdatedAt" = now()
    WHERE t."TokenHash" = p_token_hash AND t."IsUsed" = false AND t."ExpiresAt" > now()
    RETURNING t."Email" INTO v_email;

    IF v_email IS NULL THEN
        RETURN;
    END IF;

    UPDATE users AS u
    SET "EmailVerified" = true,
        "EmailVerifiedAt" = COALESCE(u."EmailVerifiedAt", now()),
        "UpdatedAt" = now()
    WHERE u."Email" = v_email AND u."EmailVerified" = false;

    RETURN QUERY
    SELECT t."Id", t."Email"::text, t."ExpiresAt"
    FROM magic_link_tokens AS t
    WHERE t."TokenHash" = p_token_hash;
END; $$;
