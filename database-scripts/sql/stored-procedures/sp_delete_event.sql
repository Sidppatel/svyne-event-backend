CREATE OR REPLACE FUNCTION sp_delete_event(p_id uuid)
RETURNS void LANGUAGE plpgsql
    SET search_path = public, extensions, pg_catalog
AS $$
BEGIN
    IF EXISTS(
        SELECT 1 FROM bookings
        WHERE events_id = p_id
          AND status IN ('Pending', 'Paid', 'CheckedIn')
    ) THEN
        RAISE EXCEPTION 'This event has active orders and cannot be cancelled. Consider marking the event as Cancelled instead.';
    END IF;
    DELETE FROM events WHERE events_id = p_id;
END; $$;
