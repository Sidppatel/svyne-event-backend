DROP FUNCTION IF EXISTS sp_calculate_price(uuid, int, timestamptz, int);
DROP FUNCTION IF EXISTS sp_calculate_price(uuid, int, timestamptz, int, int);


CREATE OR REPLACE FUNCTION sp_calculate_price(
    p_prices_id uuid, p_seats int, p_at timestamptz, p_remaining int,
    p_group_qty int DEFAULT 0
)
RETURNS TABLE(
    base_price_cents int,
    selling_price_cents int,
    discount_cents int,
    applied_price_rules_id uuid,
    applied_rule_name text,
    platform_fee_cents int,
    gateway_fee_cents int,
    tax_cents int,
    final_price_cents int,
    organizer_net_cents int,
    currency text,
    group_discounted_seats int,
    group_unit_cents int,
    standard_unit_cents int
)
LANGUAGE sql STABLE
    SET search_path = public, extensions, pg_catalog
AS $$
    SELECT * FROM app.price_breakdown(p_prices_id, COALESCE(p_at, now()), p_seats,
                           COALESCE(p_remaining, app.remaining_for_price(p_prices_id)),
                           COALESCE(NULLIF(p_group_qty, 0), p_seats),
                           COALESCE(NULLIF(p_group_qty, 0), p_seats));
$$;
