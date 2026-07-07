ALTER TABLE tenant_stripe_profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_tenant_isolation ON tenant_stripe_profiles;
CREATE POLICY p_tenant_isolation ON tenant_stripe_profiles
    USING (app.is_developer() OR tenants_id = app.current_tenant())
    WITH CHECK (app.is_developer() OR tenants_id = app.current_tenant());
