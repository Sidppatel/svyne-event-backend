CREATE OR REPLACE FUNCTION sp_create_sponsor(
    p_name text,
    p_slug text,
    p_image_path text,
    p_meta jsonb
) RETURNS uuid LANGUAGE plpgsql
SET search_path = public, extensions, pg_catalog
AS $$
DECLARE v_id uuid;
BEGIN
    INSERT INTO sponsors ("Id", "Name", "Slug", "PrimaryImagePath", "Meta", "CreatedAt", "UpdatedAt")
    VALUES (
        gen_random_uuid(),
        p_name,
        p_slug,
        NULLIF(p_image_path, ''),
        COALESCE(p_meta, '[]'::jsonb),
        now(),
        now()
    )
    RETURNING "Id" INTO v_id;
    RETURN v_id;
END; $$;
