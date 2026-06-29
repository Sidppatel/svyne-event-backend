CREATE OR REPLACE FUNCTION sp_update_tenant_contact(
    p_tenants_id uuid,
    p_phone text DEFAULT NULL,
    p_address_line1 text DEFAULT NULL,
    p_address_line2 text DEFAULT NULL,
    p_city text DEFAULT NULL,
    p_state text DEFAULT NULL,
    p_zip text DEFAULT NULL
) RETURNS void LANGUAGE plpgsql
    SET search_path = public, extensions, pg_catalog
AS $$
BEGIN
    UPDATE tenants SET
        phone         = p_phone,
        address_line1 = p_address_line1,
        address_line2 = p_address_line2,
        city          = p_city,
        state         = p_state,
        zip           = p_zip,
        updated_at    = now()
    WHERE tenants_id = p_tenants_id
      AND archived_at IS NULL;
END; $$;
