-- Sweeper: release Pending bookings whose hard hold window has elapsed without
-- payment. Flips them to 'Expired', frees the held table, and marks any
-- attached (unpaid) Stripe transaction Failed. Idempotent; safe to run on a
-- short interval from the HoldExpiryWorker. Returns the number expired.
CREATE OR REPLACE FUNCTION sp_expire_holds() RETURNS int LANGUAGE plpgsql SECURITY DEFINER
    SET search_path = public, extensions, pg_catalog
AS $$
DECLARE v_count int;
BEGIN
    WITH expired AS (
        UPDATE bookings
           SET status = 'Expired', hold_expires_at = NULL, updated_at = now()
         WHERE status = 'Pending'
           AND hold_expires_at IS NOT NULL
           AND hold_expires_at <= now()
        RETURNING bookings_id
    ),
    freed_tables AS (
        UPDATE tables t
           SET status = 'Available', locked_by_users_id = NULL,
               lock_expires_at = NULL, updated_at = now()
          FROM booking_tables bt
         WHERE bt.tables_id = t.tables_id
           AND bt.bookings_id IN (SELECT bookings_id FROM expired)
           AND t.status = 'Locked'
        RETURNING t.tables_id
    ),
    failed_tx AS (
        UPDATE stripe_transactions
           SET status = 'Failed', updated_at = now()
         WHERE bookings_id IN (SELECT bookings_id FROM expired)
           AND status NOT IN ('Succeeded', 'Refunded')
        RETURNING stripe_transactions_id
    )
    SELECT count(*) INTO v_count FROM expired;

    RETURN v_count;
END; $$;
