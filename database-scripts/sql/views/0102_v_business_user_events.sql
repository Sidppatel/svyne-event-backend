CREATE OR REPLACE VIEW vw_user_events AS
SELECT
    aue.staff_event_access_id AS user_event_id,
    aue.staff_user_id AS users_id,
    au.first_name, au.last_name, au.email,
    au.is_active AS user_is_active,
    aue.event_id AS events_id,
    e.title AS event_title, e.slug AS event_slug,
    e.start_date, e.end_date, e.status AS event_status,
    aue.assigned_by_admin_id AS assigned_by_users_id,
    aue.created_at, aue.updated_at
FROM staff_event_access aue
JOIN users au ON au.users_id = aue.staff_user_id
JOIN events e ON e.events_id = aue.event_id;
