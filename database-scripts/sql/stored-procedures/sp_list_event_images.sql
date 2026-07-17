DROP FUNCTION IF EXISTS sp_list_event_images(uuid);
DROP FUNCTION IF EXISTS sp_list_event_images(uuid, text);
CREATE OR REPLACE FUNCTION sp_list_event_images(p_event_id uuid, p_type text DEFAULT NULL)
RETURNS TABLE(
    event_image_id uuid,
    events_id uuid,
    images_id uuid,
    storage_key text,
    original_name text,
    size_bytes bigint,
    width int,
    height int,
    content_type text,
    alt_text text,
    caption text,
    is_primary boolean,
    sort_order int,
    created_at timestamptz,
    type text
) LANGUAGE sql STABLE
    SET search_path = public, extensions, pg_catalog
AS $$
    SELECT * FROM vw_event_images
    WHERE events_id = p_event_id
      AND (p_type IS NULL OR type = p_type)
    ORDER BY is_primary DESC, sort_order ASC;
$$;
