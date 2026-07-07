ALTER TABLE staff_event_access ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_tenant_isolation ON staff_event_access;
CREATE POLICY p_tenant_isolation ON staff_event_access
    USING (app.is_developer() OR EXISTS (
        SELECT 1 FROM events e
        WHERE e.events_id = staff_event_access.event_id
          AND e.tenants_id = app.current_tenant()))
    WITH CHECK (app.is_developer() OR EXISTS (
        SELECT 1 FROM events e
        WHERE e.events_id = staff_event_access.event_id
          AND e.tenants_id = app.current_tenant()));
