ALTER TABLE app_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_settings FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_read_all ON app_settings;
CREATE POLICY p_read_all ON app_settings
    FOR SELECT
    USING (true);
DROP POLICY IF EXISTS p_dev_write ON app_settings;
CREATE POLICY p_dev_write ON app_settings
    USING (app.is_developer())
    WITH CHECK (app.is_developer());
