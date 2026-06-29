DROP VIEW IF EXISTS vw_performer_public CASCADE;
CREATE OR REPLACE VIEW vw_performer_public AS
SELECT
    p.performers_id AS performers_id,
    p.name AS name,
    p.slug AS slug,
    p.primary_image_path AS primary_image_path,
    COALESCE(pm.public_meta, '[]'::jsonb) AS meta,
    COALESCE(ev.events, '[]'::jsonb) AS events
FROM performers p
LEFT JOIN LATERAL (
    SELECT jsonb_agg(elem ORDER BY COALESCE((elem->>'sortOrder')::int, 0)) AS public_meta
    FROM jsonb_array_elements(COALESCE(p.meta, '[]'::jsonb)) elem
    WHERE COALESCE((elem->>'isPublic')::bool, true) = true
) pm ON true
LEFT JOIN LATERAL (
    SELECT jsonb_agg(
        jsonb_build_object(
            'eventsId', e.events_id,
            'title', e.title,
            'slug', e.slug,
            'startDate', extract(epoch from e.start_date)::bigint,
            'primaryImagePath', prim.images_id,
            'category', COALESCE(e.category::text, '')
        )
        ORDER BY e.start_date ASC
    ) AS events
    FROM event_performers ep
    JOIN events e ON e.events_id = ep.events_id
    LEFT JOIN LATERAL (
        SELECT ei.images_id
        FROM event_images ei
        WHERE ei.events_id = e.events_id AND ei.is_primary = true
        ORDER BY CASE ei.type WHEN 'event_thumbnail' THEN 0 WHEN 'event_image' THEN 1 ELSE 2 END
        LIMIT 1
    ) prim ON true
    WHERE ep.performers_id = p.performers_id
      AND e.status = 'Published'
      AND e.start_date >= now()
) ev ON true;
