CREATE OR REPLACE FUNCTION sp_search_performers(p_q text, p_offset int, p_limit int)
RETURNS SETOF v_performers LANGUAGE sql STABLE
SET search_path = public, extensions, pg_catalog
AS $$
    SELECT v.*
    FROM v_performers v
    WHERE p_q IS NULL OR length(p_q) = 0 OR v."Name" ILIKE '%' || p_q || '%'
    ORDER BY v."UpcomingEventCount" DESC, v."Name" ASC
    OFFSET COALESCE(p_offset, 0)
    LIMIT LEAST(COALESCE(p_limit, 20), 100);
$$;
