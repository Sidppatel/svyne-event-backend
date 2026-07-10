CREATE OR REPLACE VIEW vw_enum_definitions AS
SELECT
    d.enum_type,
    d.enum_value,
    d.int_value,
    d.used_in,
    d.description
FROM enum_definitions d;
