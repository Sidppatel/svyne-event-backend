CREATE OR REPLACE FUNCTION sp_log_checkin_attempt(
    p_event_id uuid, p_staff_user_id uuid, p_booking_id uuid, p_ticket_id uuid,
    p_method text, p_status text, p_failure_reason text
) RETURNS void LANGUAGE sql
    SET search_path = public, extensions, pg_catalog
AS $$
    INSERT INTO checkin_logs (checkin_logs_id, event_id, staff_user_id, booking_id, ticket_id,
        timestamp, method, status, failure_reason, created_at, updated_at)
    VALUES (gen_random_uuid(), p_event_id, p_staff_user_id, p_booking_id, p_ticket_id,
        now(), p_method, p_status, p_failure_reason, now(), now());
$$;
