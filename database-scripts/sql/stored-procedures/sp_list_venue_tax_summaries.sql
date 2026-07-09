CREATE OR REPLACE FUNCTION sp_list_venue_tax_summaries()
RETURNS TABLE(venues_id uuid, venue_name text, tenant_name text,
              city text, state text, zip_code text,
              combined_rate numeric, state_rate numeric, county_rate numeric,
              city_rate numeric, local_rate numeric, fetched_at timestamptz)
LANGUAGE sql STABLE
    SET search_path = public, extensions, pg_catalog
AS $$
    SELECT v.venues_id, v.name::text, t.name::text,
           COALESCE(a.city, '')::text, COALESCE(a.state, '')::text, COALESCE(a.zip_code, '')::text,
           COALESCE(tr.combined_rate, 0), COALESCE(tr.state_rate, 0), COALESCE(tr.county_rate, 0),
           COALESCE(tr.city_rate, 0), COALESCE(tr.local_rate, 0), tr.fetched_at
      FROM venues v
      JOIN tenants t ON t.tenants_id = v.tenants_id
      LEFT JOIN addresses a ON a.addresses_id = v.addresses_id
      LEFT JOIN tax_rate_cache tr ON tr.zip_code = a.zip_code
     ORDER BY t.name, v.name;
$$;
