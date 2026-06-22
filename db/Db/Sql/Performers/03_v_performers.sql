CREATE OR REPLACE VIEW v_performers AS
SELECT
    p."Id" AS "PerformerId",
    p."Name" AS "Name",
    p."Slug" AS "Slug",
    p."PrimaryImagePath" AS "PrimaryImagePath",
    p."Meta" AS "Meta",
    COALESCE(ec.total, 0)::int AS "EventCount",
    COALESCE(ec.upcoming, 0)::int AS "UpcomingEventCount",
    p."CreatedAt" AS "CreatedAt",
    p."UpdatedAt" AS "UpdatedAt"
FROM performers p
LEFT JOIN LATERAL (
    SELECT
        COUNT(*)::int AS total,
        COUNT(*) FILTER (
            WHERE e."StartDate" >= now()
              AND e."Status" = 'Published'
        )::int AS upcoming
    FROM event_performers ep
    JOIN events e ON e."Id" = ep."EventId"
    WHERE ep."PerformerId" = p."Id"
) ec ON true;
