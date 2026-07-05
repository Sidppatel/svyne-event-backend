






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
