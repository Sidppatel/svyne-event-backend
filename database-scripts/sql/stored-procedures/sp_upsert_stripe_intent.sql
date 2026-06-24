-- Attach (or refresh) the PaymentIntent for a booking. Keeps exactly one live
-- stripe_transactions row per booking so resume/retry maps back to the same
-- intent. Returns the stripe_transactions_id.
CREATE OR REPLACE FUNCTION sp_upsert_stripe_intent(
    p_booking_id uuid,
    p_intent_id text,
    p_amount_cents int,
    p_transfer_amount_cents int DEFAULT NULL,
    p_currency text DEFAULT 'usd'
) RETURNS uuid LANGUAGE plpgsql
    SET search_path = public, extensions, pg_catalog
AS $$
DECLARE v_id uuid; v_tenant uuid;
BEGIN
    SELECT stripe_transactions_id INTO v_id
      FROM stripe_transactions
      WHERE bookings_id = p_booking_id
      FOR UPDATE;

    IF v_id IS NOT NULL THEN
        UPDATE stripe_transactions
           SET payment_intent_id = p_intent_id,
               amount_cents = p_amount_cents,
               transfer_amount_cents = p_transfer_amount_cents,
               currency = COALESCE(p_currency, 'usd'),
               -- Reset a previously-Failed/expired attempt back to in-flight.
               status = CASE WHEN status IN ('Succeeded', 'Refunded') THEN status
                             ELSE 'RequiresConfirmation' END,
               updated_at = now()
         WHERE stripe_transactions_id = v_id;
        RETURN v_id;
    END IF;

    SELECT tenants_id INTO v_tenant FROM bookings WHERE bookings_id = p_booking_id;

    INSERT INTO stripe_transactions (tenants_id, bookings_id, payment_intent_id, status,
        amount_cents, transfer_amount_cents, currency, created_at, updated_at)
    VALUES (v_tenant, p_booking_id, p_intent_id, 'RequiresConfirmation',
        p_amount_cents, p_transfer_amount_cents, COALESCE(p_currency, 'usd'), now(), now())
    RETURNING stripe_transactions_id INTO v_id;

    RETURN v_id;
END; $$;
