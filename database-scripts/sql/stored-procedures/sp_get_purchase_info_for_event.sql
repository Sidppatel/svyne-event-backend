CREATE OR REPLACE FUNCTION sp_get_booking_info_for_event(p_event_id uuid)
RETURNS TABLE (
    tables_id       uuid,
    booking_count int,
    seats_booked   int,
    subtotal_cents bigint
)
LANGUAGE sql STABLE
SET search_path = public, extensions, pg_catalog
AS $$
    SELECT
        bl.tables_id                                       AS tables_id,
        COUNT(*)::int                                      AS booking_count,
        COALESCE(SUM(bl.seats), 0)::int                    AS seats_booked,
        COALESCE(SUM(bl.subtotal_cents)::bigint, 0)        AS subtotal_cents
    FROM booking_lines bl
    JOIN bookings b ON b.bookings_id = bl.bookings_id
    WHERE b.events_id = p_event_id
      AND bl.kind = 'Table'
      AND bl.tables_id IS NOT NULL
      AND b.status::text IN ('Paid','CheckedIn')
    GROUP BY bl.tables_id;
$$;
