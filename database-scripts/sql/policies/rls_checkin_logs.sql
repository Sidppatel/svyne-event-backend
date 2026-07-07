ALTER TABLE checkin_logs ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_tenant_isolation ON checkin_logs;
CREATE POLICY p_tenant_isolation ON checkin_logs
    USING (app.is_developer() OR EXISTS (
        SELECT 1 FROM events e
        WHERE e.events_id = checkin_logs.event_id
          AND e.tenants_id = app.current_tenant()))
    WITH CHECK (app.is_developer() OR EXISTS (
        SELECT 1 FROM events e
        WHERE e.events_id = checkin_logs.event_id
          AND e.tenants_id = app.current_tenant()));
