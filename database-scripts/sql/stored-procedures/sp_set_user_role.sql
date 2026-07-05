CREATE OR REPLACE FUNCTION sp_set_user_role(
    p_users_id uuid, p_role int, p_allowed_from int[]
) RETURNS void LANGUAGE plpgsql
    SET search_path = public, extensions, pg_catalog
AS $$
BEGIN
    UPDATE users SET role = p_role
    WHERE users_id = p_users_id AND role = ANY(p_allowed_from);
END; $$;
