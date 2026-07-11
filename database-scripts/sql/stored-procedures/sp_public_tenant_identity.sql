CREATE OR REPLACE FUNCTION sp_public_tenant_identity()
RETURNS TABLE (
    tenants_id uuid,
    slug text,
    name text,
    archived_at timestamptz
) LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path = public, pg_catalog
AS $$
    SELECT t.tenants_id, t.slug::text, t.name::text, t.archived_at
    FROM tenants t;
$$;
