CREATE OR REPLACE VIEW vw_images AS
SELECT
    i.images_id,
    i.storage_key,
    i.content_type
FROM images i;
