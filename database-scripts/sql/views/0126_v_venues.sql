CREATE OR REPLACE VIEW vw_venues AS
SELECT
    v.venues_id AS venues_id, v.name, v.description, v.image_path,
    v.phone, v.email, v.website,
    v.is_active, v.created_at,
    COALESCE(a.line1, '') AS address_line1,
    a.line2 AS address_line2,
    COALESCE(a.city, '') AS city,
    COALESCE(a.state, '') AS state,
    COALESCE(a.zip_code, '') AS zip_code,
    COALESCE(ec.cnt, 0)::int AS event_count,
    img.storage_key AS primary_image_key,
    COALESCE(tr.state_rate, 0) AS state_tax_rate,
    COALESCE(tr.county_rate, 0) AS county_tax_rate,
    COALESCE(tr.city_rate, 0) AS city_tax_rate,
    COALESCE(tr.local_rate, 0) AS local_tax_rate,
    COALESCE(tr.combined_rate, 0) AS combined_tax_rate
FROM venues v
LEFT JOIN addresses a ON v.addresses_id = a.addresses_id
LEFT JOIN LATERAL (
    SELECT COUNT(*)::int AS cnt FROM events e WHERE e.venues_id = v.venues_id
) ec ON true
LEFT JOIN LATERAL (
    SELECT i.storage_key
    FROM venue_images vi
    JOIN images i ON i.images_id = vi.images_id
    WHERE vi.venues_id = v.venues_id AND vi.is_primary = true
    LIMIT 1
) img ON true
LEFT JOIN tax_rate_cache tr ON tr.zip_code = a.zip_code;
