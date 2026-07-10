CREATE OR REPLACE VIEW vw_fee_formulas AS
SELECT
    f.fee_formulas_id,
    f.name,
    f.percent_bps,
    f.flat_cents,
    COALESCE(f.min_fee_cents, 0) AS min_fee_cents,
    COALESCE(f.max_fee_cents, 0) AS max_fee_cents,
    f.is_active
FROM fee_formulas f;

CREATE OR REPLACE VIEW vw_event_fee_line_items AS
SELECT
    e.events_id,
    e.tenants_id,
    t.name AS tenant_name,
    e.title,
    e.status,
    li.id AS line_id,
    li.kind,
    li.label,
    li.price_cents,
    li.fee_formulas_id,
    li.fee_cents
FROM events e
JOIN tenants t ON t.tenants_id = e.tenants_id
LEFT JOIN (
    SELECT event_ticket_types_id AS id, events_id, 'ticket' AS kind, label,
           price_cents, fee_formulas_id, COALESCE(platform_fee_cents, 0) AS fee_cents
    FROM event_ticket_types WHERE is_active = true
    UNION ALL
    SELECT event_tables_id AS id, events_id, 'table' AS kind, label,
           price_cents, fee_formulas_id, COALESCE(platform_fee_cents, 0) AS fee_cents
    FROM event_tables WHERE is_active = true
) li ON li.events_id = e.events_id;
