







CREATE OR REPLACE FUNCTION sp_insert_stripe_transfer(
    p_stripe_transfer_id text,
    p_stripe_account_id text,
    p_payment_intent_id text,
    p_amount_cents int,
    p_currency text,
    p_raw_event jsonb
) RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER
    SET search_path = public, extensions, pg_catalog
AS $$
DECLARE
    v_org_id uuid;
    v_booking_id uuid;
    v_id uuid;
BEGIN
    SELECT tenants_id INTO v_org_id
    FROM tenants
    WHERE stripe_connected_account_id = p_stripe_account_id;

    IF v_org_id IS NULL THEN
        RAISE EXCEPTION 'No organization found with Stripe account %', p_stripe_account_id
            USING ERRCODE = 'no_data_found';
    END IF;

    
    
    
    IF p_payment_intent_id IS NOT NULL THEN
        SELECT bookings_id INTO v_booking_id
        FROM stripe_transactions
        WHERE payment_intent_id = p_payment_intent_id;
    END IF;

    INSERT INTO stripe_transfers (
        stripe_transfers_id, stripe_transfer_id, tenants_id, bookings_id,
        amount_cents, currency, raw_event,
        created_at, updated_at
    )
    VALUES (
        gen_random_uuid(), p_stripe_transfer_id, v_org_id, v_booking_id,
        p_amount_cents, COALESCE(p_currency, 'usd'), p_raw_event,
        now(), now()
    )
    ON CONFLICT (stripe_transfer_id) DO NOTHING
    RETURNING stripe_transfers_id INTO v_id;

    
    
    IF v_id IS NULL THEN
        SELECT stripe_transfers_id INTO v_id
        FROM stripe_transfers
        WHERE stripe_transfer_id = p_stripe_transfer_id;
    END IF;

    RETURN v_id;
END; $$;
