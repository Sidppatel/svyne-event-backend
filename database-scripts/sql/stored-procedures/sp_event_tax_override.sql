CREATE OR REPLACE FUNCTION sp_set_event_tax_override(p_event_id uuid, p_exempt bool, p_rate numeric)
RETURNS void LANGUAGE plpgsql
    SET search_path = public, extensions, pg_catalog
AS $$
BEGIN
    UPDATE events
       SET tax_exempt = p_exempt,
           tax_rate_override = CASE WHEN p_exempt THEN NULL ELSE p_rate END,
           updated_at = now()
     WHERE events_id = p_event_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Event not found' USING ERRCODE = 'P0002';
    END IF;
END; $$;

CREATE OR REPLACE FUNCTION sp_clear_event_tax_override(p_event_id uuid)
RETURNS void LANGUAGE plpgsql
    SET search_path = public, extensions, pg_catalog
AS $$
BEGIN
    UPDATE events
       SET tax_exempt = false,
           tax_rate_override = NULL,
           updated_at = now()
     WHERE events_id = p_event_id;
END; $$;

CREATE OR REPLACE FUNCTION sp_list_event_tax_overrides()
RETURNS TABLE(events_id uuid, event_title text, tenant_name text,
              tax_exempt bool, tax_rate_override numeric, updated_at timestamptz)
LANGUAGE sql STABLE
    SET search_path = public, extensions, pg_catalog
AS $$
    SELECT e.events_id, e.title::text, t.name::text,
           e.tax_exempt, e.tax_rate_override, e.updated_at
      FROM events e
      JOIN tenants t ON t.tenants_id = e.tenants_id
     WHERE e.tax_exempt OR e.tax_rate_override IS NOT NULL
     ORDER BY e.updated_at DESC;
$$;
