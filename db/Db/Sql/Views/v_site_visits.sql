-- Creates a read-only view of site page views / visits, joining audit_logs with user details.
CREATE OR REPLACE VIEW v_site_visits AS
SELECT
    al."Id"                                                        AS "Id",
    al."CreatedAt"                                                 AS "Timestamp",
    al."Action"                                                    AS "Path",
    al."Ip"                                                        AS "IpAddress",
    al."MetadataJson" ->> 'userAgent'                              AS "UserAgent",
    al."MetadataJson" ->> 'referrer'                               AS "Referrer",
    al."MetadataJson" ->> 'screenResolution'                       AS "ScreenResolution",
    al."MetadataJson" ->> 'portal'                                 AS "Portal",
    al."MetadataJson" ->> 'browser'                                AS "Browser",
    al."MetadataJson" ->> 'os'                                     AS "Os",
    CASE WHEN al."ActorType" = 'User' THEN al."ActorId" ELSE NULL END AS "UserId",
    CASE WHEN al."ActorType" IN ('Admin', 'Developer') THEN al."ActorId" ELSE NULL END AS "BusinessUserId",
    COALESCE(u."Email", bu."Email")                               AS "UserEmail",
    COALESCE(u."FirstName" || ' ' || u."LastName", bu."FirstName" || ' ' || bu."LastName") AS "UserFullName",
    COALESCE(al."ActorType"::text, 'Anonymous')                    AS "UserRole"
FROM audit_logs al
LEFT JOIN users u ON al."ActorType" = 'User' AND al."ActorId" = u."Id"
LEFT JOIN business_users bu ON al."ActorType" IN ('Admin', 'Developer') AND al."ActorId" = bu."Id"
WHERE al."EventType" = 'PageView';
