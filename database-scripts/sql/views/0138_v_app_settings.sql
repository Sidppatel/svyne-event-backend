CREATE OR REPLACE VIEW vw_app_settings AS
SELECT
    s.key,
    s.value
FROM app_settings s;
