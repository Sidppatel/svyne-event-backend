CREATE OR REPLACE FUNCTION sp_developer_tenant_stats(p_tenant uuid)
RETURNS TABLE(tier text, total_revenue_cents bigint, total_tax_cents bigint, total_tickets_sold int,
              event_count int, revenue_this_month_cents bigint, revenue_last_month_cents bigint,
              tax_this_month_cents bigint, avg_ticket_cents bigint)
LANGUAGE sql STABLE
    SET search_path = public, extensions, pg_catalog
AS $$
    WITH paid AS (
        SELECT b.bookings_id, b.subtotal_cents, COALESCE(b.seats_reserved, 1) AS seats, b.created_at
          FROM bookings b
         WHERE b.tenants_id = p_tenant AND b.status IN ('Paid','CheckedIn')
    ),
    tax AS (
        SELECT bt.tax_amount_cents, p.created_at
          FROM booking_taxes bt
          JOIN paid p ON p.bookings_id = bt.bookings_id
    )
    SELECT
        t.tier::text,
        COALESCE((SELECT SUM(subtotal_cents) FROM paid), 0)::bigint,
        COALESCE((SELECT SUM(tax_amount_cents) FROM tax), 0)::bigint,
        COALESCE((SELECT SUM(seats) FROM paid), 0)::int,
        (SELECT COUNT(*) FROM events e WHERE e.tenants_id = p_tenant)::int,
        COALESCE((SELECT SUM(subtotal_cents) FROM paid
                   WHERE created_at >= date_trunc('month', now())), 0)::bigint,
        COALESCE((SELECT SUM(subtotal_cents) FROM paid
                   WHERE created_at >= date_trunc('month', now()) - interval '1 month'
                     AND created_at < date_trunc('month', now())), 0)::bigint,
        COALESCE((SELECT SUM(tax_amount_cents) FROM tax
                   WHERE created_at >= date_trunc('month', now())), 0)::bigint,
        CASE WHEN COALESCE((SELECT SUM(seats) FROM paid), 0) = 0 THEN 0
             ELSE (SELECT SUM(subtotal_cents) FROM paid) / (SELECT SUM(seats) FROM paid) END::bigint
      FROM tenants t
     WHERE t.tenants_id = p_tenant;
$$;

CREATE OR REPLACE FUNCTION sp_developer_tenant_events(p_tenant uuid)
RETURNS TABLE(events_id uuid, event_title text, start_date timestamptz, venue_name text, status text,
              revenue_cents bigint, tickets_sold int, capacity int, tax_collected_cents bigint)
LANGUAGE sql STABLE
    SET search_path = public, extensions, pg_catalog
AS $$
    SELECT e.events_id, e.title::text, e.start_date, v.name::text, e.status::text,
           COALESCE(r.revenue, 0)::bigint, COALESCE(r.seats, 0)::int,
           COALESCE(c.capacity, 0)::int, COALESCE(tx.tax, 0)::bigint
      FROM events e
      JOIN venues v ON v.venues_id = e.venues_id
      LEFT JOIN LATERAL (
          SELECT SUM(b.subtotal_cents) AS revenue, SUM(COALESCE(b.seats_reserved, 1)) AS seats
            FROM bookings b
           WHERE b.events_id = e.events_id AND b.status IN ('Paid','CheckedIn')
      ) r ON true
      LEFT JOIN LATERAL (
          SELECT SUM(bt.tax_amount_cents) AS tax
            FROM bookings b
            JOIN booking_taxes bt ON bt.bookings_id = b.bookings_id
           WHERE b.events_id = e.events_id AND b.status IN ('Paid','CheckedIn')
      ) tx ON true
      LEFT JOIN (
          SELECT ett.events_id, SUM(ett.capacity)::int AS capacity
            FROM event_ticket_types ett
           WHERE ett.capacity IS NOT NULL
           GROUP BY ett.events_id
      ) c ON c.events_id = e.events_id
     WHERE e.tenants_id = p_tenant
     ORDER BY e.start_date DESC;
$$;

CREATE OR REPLACE FUNCTION sp_developer_tenant_revenue_by_month(p_tenant uuid)
RETURNS TABLE(bucket_start timestamptz, revenue_cents bigint, tickets_sold int)
LANGUAGE sql STABLE
    SET search_path = public, extensions, pg_catalog
AS $$
    SELECT date_trunc('month', b.created_at),
           SUM(b.subtotal_cents)::bigint, SUM(COALESCE(b.seats_reserved, 1))::int
      FROM bookings b
     WHERE b.tenants_id = p_tenant AND b.status IN ('Paid','CheckedIn')
       AND b.created_at >= date_trunc('month', now()) - interval '11 months'
     GROUP BY 1
     ORDER BY 1;
$$;

CREATE OR REPLACE FUNCTION sp_developer_tenant_tax_by_venue(p_tenant uuid)
RETURNS TABLE(venue_name text, state text, tax_collected_cents bigint, orders int)
LANGUAGE sql STABLE
    SET search_path = public, extensions, pg_catalog
AS $$
    SELECT v.name::text, MAX(COALESCE(bt.state, ''))::text,
           COALESCE(SUM(bt.tax_amount_cents), 0)::bigint, COUNT(*)::int
      FROM bookings b
      JOIN booking_taxes bt ON bt.bookings_id = b.bookings_id
      JOIN events e ON e.events_id = b.events_id
      JOIN venues v ON v.venues_id = e.venues_id
     WHERE b.tenants_id = p_tenant AND b.status IN ('Paid','CheckedIn')
     GROUP BY v.name
     ORDER BY 3 DESC;
$$;
