CREATE OR REPLACE FUNCTION sp_events_by_performer(
    p_performer_id uuid,
    p_status text,
    p_offset int,
    p_limit int
) RETURNS SETOF v_events LANGUAGE sql STABLE
SET search_path = public, extensions, pg_catalog
AS $$
    SELECT v.*
    FROM v_events v
    JOIN event_performers ep ON ep."EventId" = v."EventId"
    WHERE ep."PerformerId" = p_performer_id
      AND (p_status IS NULL OR v."Status" = p_status)
    ORDER BY v."StartDate" DESC
    OFFSET COALESCE(p_offset, 0)
    LIMIT LEAST(COALESCE(p_limit, 20), 100);
$$;
