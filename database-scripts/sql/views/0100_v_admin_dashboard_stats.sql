CREATE OR REPLACE VIEW vw_admin_dashboard_stats AS
SELECT
    (SELECT COUNT(*)::int FROM events WHERE tenants_id = app.current_tenant()) AS total_events,
    (SELECT COUNT(*)::int FROM events WHERE status::text = 'Published' AND tenants_id = app.current_tenant()) AS published_events,
    (SELECT COALESCE(SUM(COALESCE(seats_reserved, 1)), 0)::int FROM bookings b JOIN events e ON e.events_id = b.events_id WHERE b.status::text IN ('Paid','CheckedIn') AND e.tenants_id = app.current_tenant()) AS total_bookings,
    (SELECT COUNT(*)::int FROM bookings b JOIN events e ON e.events_id = b.events_id WHERE b.status::text = 'Paid' AND e.tenants_id = app.current_tenant()) AS paid_bookings,
    (SELECT COUNT(*)::int FROM bookings b JOIN events e ON e.events_id = b.events_id WHERE b.status::text = 'CheckedIn' AND e.tenants_id = app.current_tenant()) AS checked_in_bookings,
    COALESCE(
        (SELECT SUM(b.subtotal_cents)::bigint FROM bookings b JOIN events e ON e.events_id = b.events_id WHERE b.status::text IN ('Paid','CheckedIn') AND e.tenants_id = app.current_tenant()),
        0
    ) AS total_revenue_cents,
    (SELECT COUNT(*)::int FROM users WHERE tenants_id = app.current_tenant()) AS total_users,
    (SELECT COUNT(*)::int FROM venues WHERE tenants_id = app.current_tenant()) AS total_venues;
