ALTER TABLE tax_rate_cache ENABLE ROW LEVEL SECURITY;
ALTER TABLE tax_rate_cache FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_read_all ON tax_rate_cache;
CREATE POLICY p_read_all ON tax_rate_cache
    FOR SELECT
    USING (true);
DROP POLICY IF EXISTS p_cache_insert ON tax_rate_cache;
CREATE POLICY p_cache_insert ON tax_rate_cache
    FOR INSERT
    WITH CHECK (true);
DROP POLICY IF EXISTS p_cache_update ON tax_rate_cache;
CREATE POLICY p_cache_update ON tax_rate_cache
    FOR UPDATE
    USING (true)
    WITH CHECK (true);
DROP POLICY IF EXISTS p_dev_delete ON tax_rate_cache;
CREATE POLICY p_dev_delete ON tax_rate_cache
    FOR DELETE
    USING (app.is_developer());
