CREATE OR REPLACE FUNCTION sp_get_locked_table_ids(p_event_id uuid)
RETURNS TABLE(id uuid) LANGUAGE sql STABLE
    SET search_path = public, extensions, pg_catalog
AS $$
    SELECT DISTINCT bl.tables_id FROM bookings b
    JOIN booking_lines bl ON bl.bookings_id = b.bookings_id
    WHERE b.events_id = p_event_id
      AND bl.kind = 'Table'
      AND b.status IN ('Paid', 'CheckedIn', 'Pending')
    UNION
    SELECT t.tables_id FROM tables t
    WHERE t.events_id = p_event_id
      AND t.status = 'Locked'
      AND t.lock_expires_at > now();
$$;