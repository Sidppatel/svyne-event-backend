DROP FUNCTION IF EXISTS sp_set_tenant_default_fee_formula(uuid, uuid);

CREATE OR REPLACE FUNCTION sp_set_tenant_default_fee_formula(
    p_tenant_id uuid, p_fee_formulas_id uuid
) RETURNS uuid LANGUAGE plpgsql
    SET search_path = public, extensions, pg_catalog
AS $$
DECLARE v_old uuid;
BEGIN
    SELECT default_fee_formulas_id INTO v_old FROM tenants WHERE tenants_id = p_tenant_id;
    UPDATE tenants SET default_fee_formulas_id = p_fee_formulas_id, updated_at = now()
    WHERE tenants_id = p_tenant_id;
    RETURN v_old;
END; $$;
