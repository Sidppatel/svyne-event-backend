CREATE OR REPLACE FUNCTION sp_get_error_logs(
    p_severity text, p_source text, p_resolved boolean, p_search text,
    p_from timestamptz, p_to timestamptz, p_skip int, p_take int
) RETURNS SETOF vw_developer_logs LANGUAGE sql STABLE
    SET search_path = public, extensions, pg_catalog
AS $$
    SELECT * FROM vw_developer_logs
    WHERE (p_severity IS NULL OR severity = p_severity)
      AND (p_source IS NULL OR source = p_source)
      AND (p_resolved IS NULL OR resolved = p_resolved)
      AND (p_search IS NULL OR message ILIKE '%' || p_search || '%'
           OR (request_path IS NOT NULL AND request_path ILIKE '%' || p_search || '%')
           OR id::text = p_search
           OR (correlation_id IS NOT NULL AND correlation_id = p_search))
      AND (p_from IS NULL OR timestamp >= p_from)
      AND (p_to IS NULL OR timestamp <= p_to)
    ORDER BY timestamp DESC
    OFFSET p_skip LIMIT p_take;
$$;

CREATE OR REPLACE FUNCTION sp_count_error_logs(
    p_severity text, p_source text, p_resolved boolean, p_search text,
    p_from timestamptz, p_to timestamptz
) RETURNS int LANGUAGE sql STABLE
    SET search_path = public, extensions, pg_catalog
AS $$
    SELECT COUNT(*)::int FROM vw_developer_logs
    WHERE (p_severity IS NULL OR severity = p_severity)
      AND (p_source IS NULL OR source = p_source)
      AND (p_resolved IS NULL OR resolved = p_resolved)
      AND (p_search IS NULL OR message ILIKE '%' || p_search || '%'
           OR (request_path IS NOT NULL AND request_path ILIKE '%' || p_search || '%')
           OR id::text = p_search
           OR (correlation_id IS NOT NULL AND correlation_id = p_search))
      AND (p_from IS NULL OR timestamp >= p_from)
      AND (p_to IS NULL OR timestamp <= p_to);
$$;
