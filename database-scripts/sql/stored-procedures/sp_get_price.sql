DROP FUNCTION IF EXISTS sp_get_price(uuid);

CREATE OR REPLACE FUNCTION sp_get_price(p_prices_id uuid)
RETURNS TABLE(prices_id uuid, events_id uuid, name text, pricing_type text,
    base_price_cents int, per_attendee_cents int, is_all_inclusive bool,
    fee_formulas_id uuid, max_quantity int, is_active bool)
LANGUAGE sql STABLE
    SET search_path = public, extensions, pg_catalog
AS $$
    SELECT prices_id, events_id, name, pricing_type, base_price_cents,
        per_attendee_cents, is_all_inclusive, fee_formulas_id,
        max_quantity, is_active
    FROM prices WHERE prices_id = p_prices_id;
$$;
