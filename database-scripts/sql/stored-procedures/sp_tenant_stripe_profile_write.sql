CREATE OR REPLACE FUNCTION sp_upsert_tenant_stripe_profile(
    p_tenants_id uuid, p_business_type text, p_business_url text,
    p_product_description text, p_mcc text, p_support_email text
) RETURNS void LANGUAGE plpgsql SECURITY DEFINER
    SET search_path = public, extensions, pg_catalog
AS $$
BEGIN
    INSERT INTO tenant_stripe_profiles
        (tenants_id, business_type, business_url, product_description, mcc, support_email, created_at, updated_at)
    VALUES (p_tenants_id, p_business_type, p_business_url, p_product_description, p_mcc, p_support_email, now(), now())
    ON CONFLICT (tenants_id) DO UPDATE SET
        business_type = EXCLUDED.business_type,
        business_url = EXCLUDED.business_url,
        product_description = EXCLUDED.product_description,
        mcc = EXCLUDED.mcc,
        support_email = EXCLUDED.support_email,
        updated_at = now();
END; $$;

CREATE OR REPLACE FUNCTION sp_update_tenant_legal_name(p_tenants_id uuid, p_legal_name text)
RETURNS text LANGUAGE plpgsql SECURITY DEFINER
    SET search_path = public, extensions, pg_catalog
AS $$
DECLARE v_account text;
BEGIN
    UPDATE tenants SET legal_name = COALESCE(p_legal_name, legal_name), updated_at = now()
    WHERE tenants_id = p_tenants_id
    RETURNING stripe_connected_account_id INTO v_account;
    RETURN v_account;
END; $$;
