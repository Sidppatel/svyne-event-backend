CREATE OR REPLACE VIEW vw_event_checkin_stats AS
SELECT
    bl.events_id,
    COUNT(*)::int AS total,
    COUNT(*) FILTER (WHERE bl.status = 'CheckedIn')::int AS checked_in
FROM booking_lines bl
WHERE bl.kind = 'Ticket'
GROUP BY bl.events_id;

CREATE OR REPLACE VIEW vw_event_guest_bookings AS
SELECT
    b.events_id,
    b.bookings_id,
    b.booking_number,
    u.first_name AS buyer_first_name,
    u.last_name AS buyer_last_name,
    b.status::text AS status
FROM bookings b
JOIN users u ON u.users_id = b.users_id
WHERE b.status IN ('Paid', 'CheckedIn');

CREATE OR REPLACE VIEW vw_event_guest_tickets AS
SELECT
    t.events_id,
    t.booking_lines_id,
    t.bookings_id,
    t.ticket_code,
    gu.first_name AS guest_first_name,
    gu.last_name AS guest_last_name,
    bu.first_name AS buyer_first_name,
    bu.last_name AS buyer_last_name,
    t.status::text AS status,
    t.seat_number,
    (SELECT cl.timestamp FROM checkin_logs cl
     WHERE cl.ticket_id = t.booking_lines_id ORDER BY cl.timestamp DESC LIMIT 1) AS checked_in_time
FROM booking_lines t
LEFT JOIN users gu ON gu.users_id = t.guest_users_id
JOIN bookings b ON b.bookings_id = t.bookings_id
JOIN users bu ON bu.users_id = b.users_id
WHERE t.kind = 'Ticket' AND b.status IN ('Paid', 'CheckedIn');
