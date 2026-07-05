



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
          FROM booking_lines bl
         WHERE bl.tables_id = t.tables_id
           AND bl.kind = 'Table'
           AND bl.bookings_id IN (SELECT bookings_id FROM expired)
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
