CREATE OR REPLACE FUNCTION sp_resolve_error_log(
    p_audit_logs_id uuid, p_notes text, p_resolved_by uuid
) RETURNS boolean LANGUAGE plpgsql
    SET search_path = public, extensions, pg_catalog
AS $$
DECLARE v_updated int;
BEGIN
    UPDATE audit_logs
    SET metadata_json = COALESCE(metadata_json, '{}'::jsonb) || jsonb_build_object(
        'resolved', true,
        'resolved_notes', p_notes,
        'resolved_by', p_resolved_by::text,
        'resolved_at', now()
    )
    WHERE audit_logs_id = p_audit_logs_id;
    GET DIAGNOSTICS v_updated = ROW_COUNT;
    RETURN v_updated > 0;
END; $$;
