DROP FUNCTION IF EXISTS sp_list_event_price_rules(uuid);



CREATE OR REPLACE FUNCTION sp_list_event_price_rules(p_event_id uuid)
RETURNS TABLE(price_rules_id uuid, prices_id uuid, name text, rule_type text,
    priority int, price_cents int, active_from timestamptz, active_until timestamptz,
    min_remaining int, max_remaining int, is_active bool, scope text, events_id uuid,
    capacity int, min_qty int, max_qty int, discount_kind text, discount_bps int)
LANGUAGE sql STABLE
    SET search_path = public, extensions, pg_catalog
AS $$
    SELECT price_rules_id, prices_id, name, rule_type, priority, price_cents,
        active_from, active_until, min_remaining, max_remaining, is_active, scope, events_id,
        capacity, min_qty, max_qty, discount_kind, discount_bps
    FROM price_rules WHERE scope = 'Event' AND events_id = p_event_id
    ORDER BY priority DESC, created_at ASC;
$$;
