DROP FUNCTION IF EXISTS sp_report_tax_by_month_event(timestamptz, timestamptz);

CREATE OR REPLACE FUNCTION sp_report_tax_by_month_event(p_from timestamptz, p_to timestamptz)
RETURNS TABLE (
    month_start    timestamptz,
    events_id      uuid,
    event_title    text,
    tax_cents      bigint,
    taxable_cents  bigint,
    orders         int
)
LANGUAGE sql STABLE
SET search_path = public, extensions, pg_catalog
AS $$
    SELECT date_trunc('month', b.created_at),
           b.events_id,
           e.title::text,
           COALESCE(SUM(bt.tax_amount_cents), 0)::bigint,
           COALESCE(SUM(bt.taxable_amount_cents), 0)::bigint,
           COUNT(*)::int
      FROM bookings b
      JOIN booking_taxes bt ON bt.bookings_id = b.bookings_id AND bt.collected_by = 'self'
      JOIN events e ON e.events_id = b.events_id
     WHERE b.status::text IN ('Paid','CheckedIn')
       AND b.created_at >= p_from AND b.created_at < p_to
     GROUP BY 1, b.events_id, e.title
     ORDER BY 1 DESC, 4 DESC;
$$;
