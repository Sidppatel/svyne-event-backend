DROP FUNCTION IF EXISTS sp_developer_tax_remittance(timestamptz, timestamptz);

CREATE OR REPLACE FUNCTION sp_developer_tax_remittance(p_from timestamptz, p_to timestamptz)
RETURNS TABLE (
    collected_by   text,
    month_start    timestamptz,
    tenants_id     uuid,
    tenant_name    text,
    tax_cents      bigint,
    taxable_cents  bigint,
    orders         int
)
LANGUAGE sql STABLE
SET search_path = public, extensions, pg_catalog
AS $$
    SELECT bt.collected_by::text,
           date_trunc('month', b.created_at),
           b.tenants_id,
           t.name::text,
           COALESCE(SUM(bt.tax_amount_cents), 0)::bigint,
           COALESCE(SUM(bt.taxable_amount_cents), 0)::bigint,
           COUNT(*)::int
      FROM bookings b
      JOIN booking_taxes bt ON bt.bookings_id = b.bookings_id
      JOIN tenants t ON t.tenants_id = b.tenants_id
     WHERE b.status IN ('Paid','CheckedIn')
       AND b.created_at >= p_from AND b.created_at < p_to
     GROUP BY bt.collected_by, 2, b.tenants_id, t.name
     ORDER BY 1, 2 DESC, 5 DESC;
$$;
