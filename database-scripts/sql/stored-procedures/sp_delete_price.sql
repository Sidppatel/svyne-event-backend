
CREATE OR REPLACE FUNCTION sp_delete_price(p_prices_id uuid)
RETURNS void LANGUAGE plpgsql
    SET search_path = public, extensions, pg_catalog
AS $$
BEGIN
    UPDATE prices SET is_active = false, updated_at = now() WHERE prices_id = p_prices_id;
    UPDATE event_ticket_types SET is_active = false, updated_at = now() WHERE prices_id = p_prices_id;
END; $$;
