CREATE OR REPLACE FUNCTION app.event_zip(p_event uuid)
RETURNS text
LANGUAGE sql STABLE
SET search_path = public, extensions, pg_catalog
AS $$
    SELECT a.zip_code
    FROM events e
    JOIN venues v ON v.venues_id = e.venues_id
    JOIN addresses a ON a.addresses_id = v.addresses_id
    WHERE e.events_id = p_event;
$$;

CREATE OR REPLACE FUNCTION app.event_tax_rate(p_event uuid)
RETURNS numeric
LANGUAGE sql STABLE
SET search_path = public, extensions, pg_catalog
AS $$
    SELECT CASE
        WHEN e.tax_exempt THEN 0::numeric
        WHEN e.tax_rate_override IS NOT NULL THEN e.tax_rate_override
        ELSE COALESCE((
            SELECT trc.combined_rate
            FROM venues v
            JOIN addresses a ON a.addresses_id = v.addresses_id
            JOIN tax_rate_cache trc ON trc.zip_code = a.zip_code
            WHERE v.venues_id = e.venues_id
        ), 0)
    END
    FROM events e
    WHERE e.events_id = p_event;
$$;
