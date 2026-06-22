CREATE OR REPLACE VIEW v_sponsors AS
SELECT
    s."Id" AS "SponsorId",
    s."Name" AS "Name",
    s."Slug" AS "Slug",
    s."PrimaryImagePath" AS "PrimaryImagePath",
    s."Meta" AS "Meta",
    COALESCE(ec.total, 0)::int AS "EventCount",
    COALESCE(ec.upcoming, 0)::int AS "UpcomingEventCount",
    s."CreatedAt" AS "CreatedAt",
    s."UpdatedAt" AS "UpdatedAt"
FROM sponsors s
LEFT JOIN LATERAL (
    SELECT
        COUNT(*)::int AS total,
        COUNT(*) FILTER (
            WHERE e."StartDate" >= now()
              AND e."Status" = 'Published'
        )::int AS upcoming
    FROM event_sponsors es
    JOIN events e ON e."Id" = es."EventId"
    WHERE es."SponsorId" = s."Id"
) ec ON true;
