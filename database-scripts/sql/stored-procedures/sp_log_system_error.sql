CREATE OR REPLACE FUNCTION sp_log_system_error(
    p_severity text,
    p_error_type text,
    p_message text,
    p_stack_trace text,
    p_request_path text,
    p_request_method text,
    p_status_code int,
    p_source text,
    p_tenants_id uuid,
    p_users_id uuid,
    p_ip text,
    p_correlation_id uuid,
    p_extra_json text
) RETURNS uuid LANGUAGE plpgsql
    SET search_path = public, extensions, pg_catalog
AS $$
DECLARE v_id uuid;
BEGIN
    IF p_severity NOT IN ('Critical','High','Medium','Low','Warning','Info') THEN
        RAISE EXCEPTION 'invalid severity: %', p_severity;
    END IF;

    INSERT INTO audit_logs (
        audit_logs_id, tenants_id, created_at, event_type, actor_type, actor_id,
        subject_type, subject_id, action, metadata_json, ip, correlation_id
    )
    VALUES (
        gen_random_uuid(),
        p_tenants_id,
        now(),
        CASE WHEN p_severity = 'Warning' THEN 'Warning'
             WHEN p_severity = 'Info' THEN 'Info'
             ELSE 'Exception' END,
        'System',
        p_users_id,
        NULL,
        NULL,
        left(COALESCE(p_message, 'error'), 128),
        jsonb_build_object(
            'severity', p_severity,
            'exception_type', p_error_type,
            'message', p_message,
            'stack_trace', p_stack_trace,
            'request_path', p_request_path,
            'request_method', p_request_method,
            'status_code', p_status_code,
            'source', COALESCE(p_source, 'backend')
        ) || COALESCE(NULLIF(p_extra_json, '')::jsonb, '{}'::jsonb),
        p_ip,
        p_correlation_id
    )
    RETURNING audit_logs_id INTO v_id;
    RETURN v_id;
END; $$;
