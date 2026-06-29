CREATE OR REPLACE FUNCTION sp_cancel_booking(p_booking_id uuid) RETURNS void LANGUAGE plpgsql SECURITY DEFINER
    SET search_path = public, extensions, pg_catalog
AS $$
BEGIN
    -- Only a still-unpaid booking can be cancelled; never downgrade a Paid one.
    UPDATE bookings SET status = 'Cancelled', hold_expires_at = NULL, updated_at = now()
    WHERE bookings_id = p_booking_id AND status IN ('Pending', 'Expired');

    IF NOT FOUND THEN
        RETURN;
    END IF;

    -- Release any held table back to Available.
    UPDATE tables SET status = 'Available', locked_by_users_id = NULL,
        lock_expires_at = NULL, updated_at = now()
    WHERE tables_id IN (SELECT tables_id FROM booking_tables WHERE bookings_id = p_booking_id)
      AND status IN ('Locked', 'Booked');
END; $$;
