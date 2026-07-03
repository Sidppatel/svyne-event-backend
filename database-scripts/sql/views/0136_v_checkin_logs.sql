CREATE OR REPLACE VIEW vw_checkin_logs AS
SELECT
    cl.checkin_logs_id,
    cl.event_id AS events_id,
    e.tenants_id,
    e.title AS event_title,
    cl.staff_user_id,
    su.first_name || ' ' || su.last_name AS staff_name,
    cl.booking_id AS bookings_id,
    COALESCE(b.booking_number, '') AS booking_number,
    cl.ticket_id AS booking_lines_id,
    COALESCE(bl.ticket_code, '') AS ticket_code,
    bl.seat_number,
    COALESCE(
        gu.first_name || ' ' || gu.last_name,
        bu.first_name || ' ' || bu.last_name,
        '') AS attendee_name,
    COALESCE(ett.label, '') AS ticket_type_label,
    cl.timestamp,
    cl.method,
    cl.status,
    COALESCE(cl.failure_reason, '') AS failure_reason
FROM checkin_logs cl
JOIN events e ON e.events_id = cl.event_id
JOIN users su ON su.users_id = cl.staff_user_id
LEFT JOIN bookings b ON b.bookings_id = cl.booking_id
LEFT JOIN booking_lines bl ON bl.booking_lines_id = cl.ticket_id
LEFT JOIN users gu ON gu.users_id = bl.guest_users_id
LEFT JOIN users bu ON bu.users_id = b.users_id
LEFT JOIN event_ticket_types ett ON ett.event_ticket_types_id = bl.event_ticket_types_id;
