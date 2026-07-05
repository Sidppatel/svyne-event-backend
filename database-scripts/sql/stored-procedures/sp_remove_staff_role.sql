CREATE OR REPLACE FUNCTION sp_remove_staff_role(
    p_users_id uuid, p_tenants_id uuid, p_role int
) RETURNS void LANGUAGE plpgsql
    SET search_path = public, extensions, pg_catalog
AS $$
BEGIN
    DELETE FROM staff_event_access WHERE staff_user_id = p_users_id;
    UPDATE users SET role = p_role
    WHERE users_id = p_users_id AND tenants_id = p_tenants_id;
END; $$;
