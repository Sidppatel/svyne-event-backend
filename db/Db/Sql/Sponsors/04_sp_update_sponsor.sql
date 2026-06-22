CREATE OR REPLACE FUNCTION sp_update_sponsor(
    p_id uuid,
    p_name text,
    p_slug text,
    p_image_path text,
    p_meta jsonb
) RETURNS void LANGUAGE plpgsql
SET search_path = public, extensions, pg_catalog
AS $$
BEGIN
    UPDATE sponsors SET
        "Name" = COALESCE(p_name, "Name"),
        "Slug" = COALESCE(p_slug, "Slug"),
        "PrimaryImagePath" = CASE
            WHEN p_image_path IS NULL THEN "PrimaryImagePath"
            WHEN p_image_path = '' THEN NULL
            ELSE p_image_path
        END,
        "Meta" = COALESCE(p_meta, "Meta"),
        "UpdatedAt" = now()
    WHERE "Id" = p_id;
END; $$;
