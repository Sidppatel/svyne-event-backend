



CREATE OR REPLACE FUNCTION sp_calculate_price(
    p_prices_id uuid, p_seats int, p_at timestamptz, p_remaining int
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
    currency text
)
LANGUAGE sql STABLE
    SET search_path = public, extensions, pg_catalog
AS $$
    SELECT * FROM app.price_breakdown(p_prices_id, COALESCE(p_at, now()), p_seats,
                           COALESCE(p_remaining, app.remaining_for_price(p_prices_id)));
$$;
