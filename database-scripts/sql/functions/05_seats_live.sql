-- Live-seat accounting. Every booking now records its seats on booking_lines
-- (one unified model; no legacy single-line columns). "Live" = Paid/CheckedIn, or
-- Pending while its hold is still in the future. These feed the oversell guards in
-- sp_reserve_open_capacity, sp_create_multi_booking and app.remaining_for_price so
-- a tier/event cap can never be exceeded.

-- Total live seats for an event (tickets + tables), used for the event-level cap.
CREATE OR REPLACE FUNCTION app.event_seats_live(p_event uuid)
RETURNS int
LANGUAGE sql STABLE
SET search_path = public, extensions, pg_catalog
AS $$
    SELECT COALESCE(SUM(bl.seats), 0)::int
      FROM booking_lines bl
      JOIN bookings b ON b.bookings_id = bl.bookings_id
     WHERE b.events_id = p_event
       AND (b.status IN ('Paid', 'CheckedIn')
            OR (b.status = 'Pending' AND (b.hold_expires_at IS NULL OR b.hold_expires_at > now())));
$$;

-- Live seats sold/held for a single ticket tier, used for the per-tier max cap
-- and remaining inventory.
CREATE OR REPLACE FUNCTION app.ticket_type_seats_live(p_type uuid)
RETURNS int
LANGUAGE sql STABLE
SET search_path = public, extensions, pg_catalog
AS $$
    SELECT COALESCE(SUM(bl.seats), 0)::int
      FROM booking_lines bl
      JOIN bookings b ON b.bookings_id = bl.bookings_id
     WHERE bl.kind = 'Ticket'
       AND bl.event_ticket_types_id = p_type
       AND (b.status IN ('Paid', 'CheckedIn')
            OR (b.status = 'Pending' AND (b.hold_expires_at IS NULL OR b.hold_expires_at > now())));
$$;
