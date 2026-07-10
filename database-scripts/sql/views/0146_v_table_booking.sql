CREATE OR REPLACE VIEW vw_event_layout_tables AS
SELECT
    t.events_id,
    t.sort_order,
    t.tables_id,
    t.event_tables_id,
    t.label,
    t.pos_x,
    t.pos_y,
    t.width,
    t.height,
    t.status::text,
    COALESCE(et.price_cents, 0) AS price_cents,
    COALESCE(et.platform_fee_cents, 0) AS platform_fee_cents,
    et.fee_formulas_id,
    t.shape_override,
    t.color_override,
    t.capacity_override,
    et.prices_id
FROM tables t
LEFT JOIN event_tables et ON et.event_tables_id = t.event_tables_id;

CREATE OR REPLACE VIEW vw_event_table_types AS
SELECT
    et.events_id,
    et.is_active,
    et.event_tables_id,
    et.label,
    et.capacity,
    et.shape,
    COALESCE(et.color, '') AS color,
    et.price_cents,
    et.prices_id,
    COALESCE(et.default_width, 80) AS default_width,
    COALESCE(et.default_height, 80) AS default_height,
    COALESCE(et.platform_fee_cents, 0) AS platform_fee_cents
FROM event_tables et;

CREATE OR REPLACE VIEW vw_table_templates AS
SELECT
    tt.tenants_id,
    tt.table_templates_id,
    tt.name,
    tt.default_capacity,
    tt.default_shape,
    COALESCE(tt.default_color, '') AS default_color,
    tt.default_price_cents,
    tt.is_active,
    COALESCE(tt.default_width, 80) AS default_width,
    COALESCE(tt.default_height, 80) AS default_height,
    tt.default_is_all_inclusive
FROM table_templates tt;
