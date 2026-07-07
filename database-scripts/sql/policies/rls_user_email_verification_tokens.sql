ALTER TABLE user_email_verification_tokens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_owner_isolation ON user_email_verification_tokens;
CREATE POLICY p_owner_isolation ON user_email_verification_tokens
    USING (app.is_developer() OR users_id = app.current_user_id())
    WITH CHECK (app.is_developer() OR users_id = app.current_user_id());
