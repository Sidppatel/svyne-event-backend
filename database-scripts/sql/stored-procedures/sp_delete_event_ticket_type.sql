CREATE OR REPLACE FUNCTION sp_delete_event_ticket_type(p_id uuid) RETURNS void LANGUAGE plpgsql
    SET search_path = public, extensions, pg_catalog
AS $$
DECLARE v_sold int;
BEGIN
    SELECT COALESCE(SUM(bl.seats), 0)::int INTO v_sold
      FROM booking_lines bl
      JOIN bookings b ON b.bookings_id = bl.bookings_id
     WHERE bl.kind = 'Ticket'
       AND bl.event_ticket_types_id = p_id
       AND b.status IN ('Pending', 'Paid', 'CheckedIn');

    IF v_sold > 0 THEN
        RAISE EXCEPTION 'This ticket type cannot be deleted because % attendees have already purchased it.', v_sold;
    END IF;

    UPDATE event_ticket_types SET is_active = false, updated_at = now() WHERE event_ticket_types_id = p_id;
END; $$;
