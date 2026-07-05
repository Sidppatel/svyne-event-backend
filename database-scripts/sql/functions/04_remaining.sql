





CREATE OR REPLACE FUNCTION app.remaining_for_price(p_prices_id uuid)
RETURNS int
LANGUAGE plpgsql STABLE
SET search_path = public, extensions, pg_catalog
AS $$
DECLARE v_type text; v_max int; v_remaining int; v_sold int;
BEGIN
    SELECT pricing_type, max_quantity INTO v_type, v_max
      FROM prices WHERE prices_id = p_prices_id;
    IF NOT FOUND THEN RETURN NULL; END IF;

    IF v_type = 'Table' THEN
        SELECT count(*) INTO v_remaining
          FROM tables t
          JOIN event_tables et ON et.event_tables_id = t.event_tables_id
         WHERE et.prices_id = p_prices_id
           AND t.is_active = true
           AND t.status = 'Available';
        RETURN v_remaining;
    END IF;

    
    
    IF v_max IS NULL THEN
        SELECT max_quantity INTO v_max
          FROM event_ticket_types WHERE prices_id = p_prices_id LIMIT 1;
    END IF;
    IF v_max IS NULL THEN RETURN NULL; END IF;  

    
    
    SELECT COALESCE(SUM(app.ticket_type_seats_live(ett.event_ticket_types_id)), 0) INTO v_sold
      FROM event_ticket_types ett
     WHERE ett.prices_id = p_prices_id;

    v_remaining := GREATEST(v_max - v_sold, 0);
    RETURN v_remaining;
END; $$;
