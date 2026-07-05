






CREATE OR REPLACE FUNCTION sp_mark_booking_processing(p_intent_id text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER
    SET search_path = public, extensions, pg_catalog
AS $$
DECLARE v_booking uuid;
BEGIN
    SELECT bookings_id INTO v_booking
      FROM stripe_transactions WHERE payment_intent_id = p_intent_id;
    IF v_booking IS NULL THEN
        RETURN;
    END IF;
    UPDATE bookings SET hold_expires_at = NULL, updated_at = now()
     WHERE bookings_id = v_booking AND status = 'Pending';
END; $$;






CREATE OR REPLACE FUNCTION sp_fail_booking_payment(p_intent_id text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER
    SET search_path = public, extensions, pg_catalog
AS $$
DECLARE v_booking uuid; v_status text; v_hold timestamptz;
BEGIN
    UPDATE stripe_transactions SET status = 'Failed', updated_at = now()
     WHERE payment_intent_id = p_intent_id AND status NOT IN ('Succeeded', 'Refunded');

    SELECT b.bookings_id, b.status, b.hold_expires_at
      INTO v_booking, v_status, v_hold
      FROM bookings b
      JOIN stripe_transactions st ON st.bookings_id = b.bookings_id
     WHERE st.payment_intent_id = p_intent_id;

    IF v_booking IS NOT NULL AND v_status = 'Pending' AND v_hold IS NULL THEN
        PERFORM sp_cancel_booking(v_booking);
    END IF;
END; $$;
