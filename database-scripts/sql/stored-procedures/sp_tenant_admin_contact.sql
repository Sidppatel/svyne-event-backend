CREATE OR REPLACE FUNCTION sp_tenant_admin_contact(p_tenants_id uuid, p_admin_role int)
RETURNS TABLE (email text, tenant_name text) LANGUAGE sql STABLE
    SET search_path = public, extensions, pg_catalog
AS $$
    SELECT u.email::text, t.name::text
    FROM users u
    JOIN tenants t ON t.tenants_id = u.tenants_id
    WHERE u.tenants_id = p_tenants_id AND u.role = p_admin_role
    ORDER BY u.created_at
    LIMIT 1;
$$;
