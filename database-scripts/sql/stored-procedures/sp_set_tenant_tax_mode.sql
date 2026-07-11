DROP FUNCTION IF EXISTS sp_set_tenant_tax_mode(uuid, text);




CREATE OR REPLACE FUNCTION sp_set_tenant_tax_mode(
    p_tenants_id uuid, p_mode text
) RETURNS jsonb LANGUAGE plpgsql
    SET search_path = public, extensions, pg_catalog
AS $$
DECLARE v_old_mode text;
BEGIN
    IF p_mode NOT IN ('platform', 'self') THEN
        RAISE EXCEPTION 'unknown tax collection mode: %', p_mode USING ERRCODE = '22023';
    END IF;
    SELECT tax_collection_mode INTO v_old_mode
      FROM tenants WHERE tenants_id = p_tenants_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'tenant not found: %', p_tenants_id;
    END IF;
    UPDATE tenants
       SET tax_collection_mode = p_mode,
           updated_at = now()
     WHERE tenants_id = p_tenants_id;
    RETURN jsonb_build_object('mode', v_old_mode);
END; $$;
