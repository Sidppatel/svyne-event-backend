CREATE OR REPLACE FUNCTION sp_set_event_primary_image(
    p_event_id uuid,
    p_image_id uuid
) RETURNS boolean LANGUAGE plpgsql
    SET search_path = public, extensions, pg_catalog
AS $$
DECLARE
    v_type text;
BEGIN
    SELECT type INTO v_type FROM event_images
    WHERE events_id = p_event_id AND images_id = p_image_id;

    IF v_type IS NULL THEN
        RETURN false;
    END IF;

    UPDATE event_images
    SET is_primary = false, updated_at = now()
    WHERE events_id = p_event_id AND type = v_type AND is_primary = true;

    UPDATE event_images
    SET is_primary = true, updated_at = now()
    WHERE events_id = p_event_id AND images_id = p_image_id;

    RETURN true;
END; $$;
