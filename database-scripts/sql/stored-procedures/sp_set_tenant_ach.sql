DROP FUNCTION IF EXISTS sp_set_tenant_ach(uuid, boolean, uuid);




CREATE OR REPLACE FUNCTION sp_set_tenant_ach(
    p_tenants_id uuid, p_enabled boolean, p_fee_formulas_id uuid
) RETURNS jsonb LANGUAGE plpgsql
    SET search_path = public, extensions, pg_catalog
AS $$
DECLARE v_old_enabled boolean;
        v_old_formula uuid;
BEGIN
    SELECT ach_enabled, ach_fee_formulas_id INTO v_old_enabled, v_old_formula
      FROM tenants WHERE tenants_id = p_tenants_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'tenant not found: %', p_tenants_id;
    END IF;
    IF p_enabled AND p_fee_formulas_id IS NULL THEN
        RAISE EXCEPTION 'an ACH fee formula is required to enable ACH' USING ERRCODE = '22023';
    END IF;
    UPDATE tenants
       SET ach_enabled = p_enabled,
           ach_fee_formulas_id = CASE WHEN p_enabled THEN p_fee_formulas_id ELSE ach_fee_formulas_id END,
           updated_at = now()
     WHERE tenants_id = p_tenants_id;
    RETURN jsonb_build_object(
        'enabled', COALESCE(v_old_enabled, false),
        'fee_formulas_id', v_old_formula);
END; $$;
