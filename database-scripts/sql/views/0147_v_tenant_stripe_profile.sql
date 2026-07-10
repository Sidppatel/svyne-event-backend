CREATE OR REPLACE VIEW vw_tenant_stripe_profile AS
SELECT
    t.tenants_id,
    t.stripe_connected_account_id,
    t.country_code,
    COALESCE(t.legal_name, t.name) AS business_name,
    p.business_type,
    p.business_url,
    p.product_description,
    p.mcc,
    p.support_email
FROM tenants t
LEFT JOIN tenant_stripe_profiles p ON p.tenants_id = t.tenants_id;
