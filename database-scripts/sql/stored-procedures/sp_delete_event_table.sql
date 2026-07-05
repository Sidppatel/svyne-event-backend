CREATE OR REPLACE FUNCTION sp_delete_event_table(p_id uuid)
RETURNS void LANGUAGE plpgsql
    SET search_path = public, extensions, pg_catalog
AS $$
DECLARE v_price uuid;
BEGIN
    
    
    IF EXISTS(
        SELECT 1 FROM tables
        WHERE event_tables_id = p_id
          AND (status = 'Booked' OR (status = 'Locked' AND lock_expires_at > now()))
    ) THEN
        RAISE EXCEPTION 'Cannot remove this table type: it has sold or held tables';
    END IF;
    SELECT prices_id INTO v_price FROM event_tables WHERE event_tables_id = p_id;
    DELETE FROM tables WHERE event_tables_id = p_id;
    DELETE FROM event_tables WHERE event_tables_id = p_id;
    
    
    IF v_price IS NOT NULL THEN
        DELETE FROM prices WHERE prices_id = v_price;
    END IF;
END; $$;
