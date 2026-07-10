CREATE OR REPLACE VIEW vw_booking_ticket_lines AS
SELECT
    bl.bookings_id,
    bl.ticket_code,
    bl.seat_number
FROM booking_lines bl
WHERE bl.kind = 'Ticket';
