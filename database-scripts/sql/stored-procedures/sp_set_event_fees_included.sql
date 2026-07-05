


CREATE OR REPLACE FUNCTION sp_set_event_fees_included(p_event_id uuid, p_included bool)
RETURNS void LANGUAGE plpgsql
    SET search_path = public, extensions, pg_catalog
AS $$
BEGIN
    UPDATE events SET fees_included = p_included, updated_at = now()
    WHERE events_id = p_event_id;
END; $$;
