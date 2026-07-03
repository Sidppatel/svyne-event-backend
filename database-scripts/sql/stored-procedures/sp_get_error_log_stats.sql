CREATE OR REPLACE FUNCTION sp_get_error_log_stats()
RETURNS jsonb LANGUAGE sql STABLE
    SET search_path = public, extensions, pg_catalog
AS $$
    SELECT jsonb_build_object(
        'total_today', (SELECT COUNT(*) FROM vw_developer_logs WHERE timestamp >= date_trunc('day', now())),
        'total_week', (SELECT COUNT(*) FROM vw_developer_logs WHERE timestamp >= now() - interval '7 days'),
        'total_month', (SELECT COUNT(*) FROM vw_developer_logs WHERE timestamp >= now() - interval '30 days'),
        'unresolved', (SELECT COUNT(*) FROM vw_developer_logs
                       WHERE NOT resolved AND severity IN ('Critical', 'High', 'Medium', 'Low', 'Error')),
        'by_severity', (SELECT COALESCE(jsonb_object_agg(severity, cnt), '{}'::jsonb)
                        FROM (SELECT severity, COUNT(*) AS cnt FROM vw_developer_logs
                              WHERE timestamp >= now() - interval '30 days'
                              GROUP BY severity) s),
        'daily', (SELECT COALESCE(jsonb_object_agg(day, cnt), '{}'::jsonb)
                  FROM (SELECT to_char(date_trunc('day', timestamp), 'YYYY-MM-DD') AS day, COUNT(*) AS cnt
                        FROM vw_developer_logs
                        WHERE timestamp >= now() - interval '14 days'
                        GROUP BY 1) d),
        'top_types', (SELECT COALESCE(jsonb_object_agg(t, cnt), '{}'::jsonb)
                      FROM (SELECT COALESCE(exception_type, 'unknown') AS t, COUNT(*) AS cnt
                            FROM vw_developer_logs
                            WHERE timestamp >= now() - interval '30 days'
                            GROUP BY 1 ORDER BY cnt DESC LIMIT 10) tt),
        'top_tenants', (SELECT COALESCE(jsonb_object_agg(slug, cnt), '{}'::jsonb)
                        FROM (SELECT tn.slug AS slug, COUNT(*) AS cnt
                              FROM vw_developer_logs dl
                              JOIN tenants tn ON tn.tenants_id = dl.tenants_id
                              WHERE dl.timestamp >= now() - interval '30 days'
                              GROUP BY tn.slug ORDER BY cnt DESC LIMIT 10) tc)
    );
$$;
