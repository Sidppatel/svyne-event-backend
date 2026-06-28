DROP FUNCTION IF EXISTS sp_list_event_images(uuid);
DROP FUNCTION IF EXISTS sp_list_event_images(uuid, text);
CREATE OR REPLACE FUNCTION sp_list_event_images(p_event_id uuid, p_type text DEFAULT NULL)
RETURNS SETOF vw_event_images LANGUAGE sql STABLE
    SET search_path = public, extensions, pg_catalog
AS $$
    SELECT * FROM vw_event_images
    WHERE events_id = p_event_id
      AND (p_type IS NULL OR type = p_type)
    ORDER BY is_primary DESC, sort_order ASC;
$$;
