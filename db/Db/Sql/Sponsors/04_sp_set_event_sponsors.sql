CREATE OR REPLACE FUNCTION sp_set_event_sponsors(p_event_id uuid, p_links jsonb)
RETURNS void LANGUAGE plpgsql
SET search_path = public, extensions, pg_catalog
AS $$
BEGIN
    DELETE FROM event_sponsors WHERE "EventId" = p_event_id;
    INSERT INTO event_sponsors ("EventId", "SponsorId", "SortOrder", "EventMeta", "CreatedAt")
    SELECT
        p_event_id,
        (link->>'sponsorId')::uuid,
        COALESCE((link->>'sortOrder')::int, 0),
        COALESCE(link->'eventMeta', '[]'::jsonb),
        now()
    FROM jsonb_array_elements(COALESCE(p_links, '[]'::jsonb)) link;
END; $$;
