CREATE OR REPLACE FUNCTION sp_developer_tax_by_event(p_from timestamptz, p_to timestamptz)
RETURNS TABLE(events_id uuid, event_title text, tax_collected_cents bigint, orders int)
LANGUAGE sql STABLE
    SET search_path = public, extensions, pg_catalog
AS $$
    SELECT b.events_id, e.title::text,
           COALESCE(SUM(bt.tax_amount_cents), 0)::bigint, COUNT(*)::int
      FROM bookings b
      JOIN booking_taxes bt ON bt.bookings_id = b.bookings_id AND bt.collected_by = 'platform'
      JOIN events e ON e.events_id = b.events_id
     WHERE b.status IN ('Paid','CheckedIn')
       AND b.created_at >= p_from AND b.created_at < p_to
     GROUP BY b.events_id, e.title
     ORDER BY 3 DESC;
$$;

CREATE OR REPLACE FUNCTION sp_developer_tax_by_tenant(p_from timestamptz, p_to timestamptz)
RETURNS TABLE(tenants_id uuid, name text, tax_collected_cents bigint, orders int)
LANGUAGE sql STABLE
    SET search_path = public, extensions, pg_catalog
AS $$
    SELECT b.tenants_id, t.name::text,
           COALESCE(SUM(bt.tax_amount_cents), 0)::bigint, COUNT(*)::int
      FROM bookings b
      JOIN booking_taxes bt ON bt.bookings_id = b.bookings_id AND bt.collected_by = 'platform'
      JOIN tenants t ON t.tenants_id = b.tenants_id
     WHERE b.status IN ('Paid','CheckedIn')
       AND b.created_at >= p_from AND b.created_at < p_to
     GROUP BY b.tenants_id, t.name
     ORDER BY 3 DESC;
$$;

CREATE OR REPLACE FUNCTION sp_developer_tax_by_month(p_from timestamptz, p_to timestamptz)
RETURNS TABLE(bucket_start timestamptz, tax_collected_cents bigint, orders int)
LANGUAGE sql STABLE
    SET search_path = public, extensions, pg_catalog
AS $$
    SELECT date_trunc('month', b.created_at),
           COALESCE(SUM(bt.tax_amount_cents), 0)::bigint, COUNT(*)::int
      FROM bookings b
      JOIN booking_taxes bt ON bt.bookings_id = b.bookings_id AND bt.collected_by = 'platform'
     WHERE b.status IN ('Paid','CheckedIn')
       AND b.created_at >= p_from AND b.created_at < p_to
     GROUP BY 1
     ORDER BY 1;
$$;

DROP FUNCTION IF EXISTS sp_developer_tax_by_jurisdiction(timestamptz, timestamptz);
CREATE OR REPLACE FUNCTION sp_developer_tax_by_jurisdiction(p_from timestamptz, p_to timestamptz)
RETURNS TABLE(state text, county text, city text, combined_rate numeric,
              state_rate numeric, county_rate numeric, city_rate numeric, local_rate numeric,
              tax_collected_cents bigint,
              state_tax_cents bigint, county_tax_cents bigint, city_tax_cents bigint,
              orders int)
LANGUAGE sql STABLE
    SET search_path = public, extensions, pg_catalog
AS $$
    SELECT COALESCE(bt.state, ''), COALESCE(bt.county, ''), COALESCE(bt.city, ''),
           MAX(bt.combined_rate),
           MAX(bt.state_rate), MAX(bt.county_rate), MAX(bt.city_rate), MAX(bt.local_rate),
           COALESCE(SUM(bt.tax_amount_cents), 0)::bigint,
           COALESCE(round(SUM(bt.taxable_amount_cents * bt.state_rate)), 0)::bigint,
           COALESCE(round(SUM(bt.taxable_amount_cents * bt.county_rate)), 0)::bigint,
           COALESCE(round(SUM(bt.taxable_amount_cents * bt.city_rate)), 0)::bigint,
           COUNT(*)::int
      FROM bookings b
      JOIN booking_taxes bt ON bt.bookings_id = b.bookings_id AND bt.collected_by = 'platform'
     WHERE b.status IN ('Paid','CheckedIn')
       AND b.created_at >= p_from AND b.created_at < p_to
     GROUP BY 1, 2, 3
     ORDER BY 9 DESC;
$$;

CREATE OR REPLACE FUNCTION sp_developer_tax_rate_summary(p_from timestamptz, p_to timestamptz)
RETURNS TABLE(combined_rate numeric, state text, tax_collected_cents bigint, orders int)
LANGUAGE sql STABLE
    SET search_path = public, extensions, pg_catalog
AS $$
    SELECT bt.combined_rate, COALESCE(bt.state, ''),
           COALESCE(SUM(bt.tax_amount_cents), 0)::bigint, COUNT(*)::int
      FROM bookings b
      JOIN booking_taxes bt ON bt.bookings_id = b.bookings_id AND bt.collected_by = 'platform'
     WHERE b.status IN ('Paid','CheckedIn')
       AND b.created_at >= p_from AND b.created_at < p_to
     GROUP BY bt.combined_rate, bt.state
     ORDER BY 3 DESC;
$$;
