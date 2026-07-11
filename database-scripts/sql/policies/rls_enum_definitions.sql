ALTER TABLE enum_definitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE enum_definitions FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_read_all ON enum_definitions;
CREATE POLICY p_read_all ON enum_definitions
    FOR SELECT
    USING (true);
DROP POLICY IF EXISTS p_dev_write ON enum_definitions;
CREATE POLICY p_dev_write ON enum_definitions
    USING (app.is_developer())
    WITH CHECK (app.is_developer());
