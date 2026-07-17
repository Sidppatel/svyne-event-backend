CREATE OR REPLACE FUNCTION sp_list_venue_images(p_venue_id uuid)
RETURNS TABLE(
    venue_image_id uuid,
    venues_id uuid,
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
    created_at timestamptz
) LANGUAGE sql STABLE
    SET search_path = public, extensions, pg_catalog
AS $$
    SELECT * FROM vw_venue_images
    WHERE venues_id = p_venue_id
    ORDER BY sort_order ASC;
$$;
