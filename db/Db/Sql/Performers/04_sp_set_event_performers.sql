CREATE OR REPLACE FUNCTION sp_set_event_performers(p_event_id uuid, p_links jsonb)
RETURNS void LANGUAGE plpgsql
SET search_path = public, extensions, pg_catalog
AS $$
BEGIN
    DELETE FROM event_performers WHERE "EventId" = p_event_id;
    INSERT INTO event_performers ("EventId", "PerformerId", "SortOrder", "EventMeta", "CreatedAt")
    SELECT
        p_event_id,
        (link->>'performerId')::uuid,
        COALESCE((link->>'sortOrder')::int, 0),
        COALESCE(link->'eventMeta', '[]'::jsonb),
        now()
    FROM jsonb_array_elements(COALESCE(p_links, '[]'::jsonb)) link;
END; $$;
