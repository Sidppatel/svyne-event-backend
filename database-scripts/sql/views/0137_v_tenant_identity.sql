CREATE OR REPLACE VIEW vw_tenant_identity AS
SELECT
    t.tenants_id AS tenants_id,
    t.slug,
    t.archived_at,
    t.name
FROM tenants t;
