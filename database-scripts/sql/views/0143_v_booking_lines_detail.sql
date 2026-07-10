CREATE OR REPLACE VIEW vw_booking_lines_detail AS
SELECT
    bl.bookings_id,
    bl.created_at,
    bl.booking_lines_id,
    bl.kind,
    COALESCE(ett.label, t.label, '') AS label,
    bl.event_ticket_types_id,
    bl.tables_id,
    bl.seats,
    bl.subtotal_cents,
    bl.fee_cents,
    bl.total_cents,
    bl.base_price_cents,
    bl.selling_price_cents,
    bl.discount_cents,
    COALESCE(bl.applied_rule_name, '') AS applied_rule_name,
    bl.platform_fee_cents,
    bl.gateway_fee_cents,
    bl.final_price_cents,
    bl.currency
FROM booking_lines bl
LEFT JOIN event_ticket_types ett ON ett.event_ticket_types_id = bl.event_ticket_types_id
LEFT JOIN tables t ON t.tables_id = bl.tables_id;
