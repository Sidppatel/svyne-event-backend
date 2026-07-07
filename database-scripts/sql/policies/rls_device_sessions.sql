ALTER TABLE device_sessions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_owner_isolation ON device_sessions;
CREATE POLICY p_owner_isolation ON device_sessions
    USING (app.is_developer() OR users_id = app.current_user_id())
    WITH CHECK (app.is_developer() OR users_id = app.current_user_id());
