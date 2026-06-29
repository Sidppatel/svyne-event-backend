CREATE OR REPLACE FUNCTION sp_user_event_exists(
    p_users_id uuid, p_events_id uuid
) RETURNS boolean LANGUAGE sql STABLE
    SET search_path = public, extensions, pg_catalog
AS $$
    SELECT EXISTS(
        SELECT 1 FROM staff_event_access
        WHERE staff_user_id = p_users_id AND event_id = p_events_id
    );
$$;
