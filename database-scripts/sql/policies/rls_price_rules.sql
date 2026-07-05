ALTER TABLE price_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE price_rules FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_tenant_isolation ON price_rules;


CREATE POLICY p_tenant_isolation ON price_rules
    USING (app.is_developer() OR (tenants_id = app.current_tenant()
        AND app.can_access_event(COALESCE(events_id, (SELECT p.events_id FROM prices p WHERE p.prices_id = price_rules.prices_id)))))
    WITH CHECK (app.is_developer() OR (tenants_id = app.current_tenant()
        AND app.can_access_event(COALESCE(events_id, (SELECT p.events_id FROM prices p WHERE p.prices_id = price_rules.prices_id)))));
