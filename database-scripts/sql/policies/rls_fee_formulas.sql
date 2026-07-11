ALTER TABLE fee_formulas ENABLE ROW LEVEL SECURITY;
ALTER TABLE fee_formulas FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_read_all ON fee_formulas;
CREATE POLICY p_read_all ON fee_formulas
    FOR SELECT
    USING (true);
DROP POLICY IF EXISTS p_dev_write ON fee_formulas;
CREATE POLICY p_dev_write ON fee_formulas
    USING (app.is_developer())
    WITH CHECK (app.is_developer());
