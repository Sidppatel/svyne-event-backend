CREATE OR REPLACE FUNCTION fn_audit_trigger() RETURNS trigger LANGUAGE plpgsql
    SET search_path = public, extensions, pg_catalog
AS $$
DECLARE
    v_action text;
    v_subject_id uuid;
    v_events_id uuid;
    v_before jsonb;
    v_after  jsonb;
    v_actor uuid := nullif(current_setting('app.current_user_id', true), '')::uuid;
    v_tenant uuid := nullif(current_setting('app.current_tenant', true), '')::uuid;
    v_actor_type text;
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_action := 'Delete';
        v_before := to_jsonb(OLD) - 'password_hash';
        v_after  := NULL;
    ELSIF TG_OP = 'UPDATE' THEN
        v_before := to_jsonb(OLD) - 'password_hash';
        v_after  := to_jsonb(NEW) - 'password_hash';
        IF (v_before ->> 'is_active') = 'true' AND (v_after ->> 'is_active') = 'false' THEN
            v_action := 'Delete';
        ELSE
            v_action := 'Update';
        END IF;
    ELSIF TG_OP = 'INSERT' THEN
        v_action := 'Insert';
        v_before := NULL;
        v_after  := to_jsonb(NEW) - 'password_hash';
    ELSE
        RETURN NULL;
    END IF;

    v_subject_id := (coalesce(v_after, v_before) ->> (TG_TABLE_NAME || '_id'))::uuid;
    v_events_id := nullif(coalesce(v_after, v_before) ->> 'events_id', '')::uuid;

    v_actor_type := CASE
        WHEN v_actor IS NULL THEN 'System'
        WHEN v_tenant IS NULL THEN 'Developer'
        ELSE 'Admin'
    END;

    INSERT INTO audit_logs (
        audit_logs_id, tenants_id, created_at, event_type, actor_type, actor_id,
        subject_type, subject_id, events_id, action, metadata_json, ip, correlation_id
    )
    VALUES (
        gen_random_uuid(), v_tenant, now(), 'EntityChange', v_actor_type, v_actor,
        TG_TABLE_NAME, v_subject_id, v_events_id, v_action,
        jsonb_build_object('before', v_before, 'after', v_after, 'source', TG_TABLE_NAME),
        NULL, NULL
    );

    IF TG_OP = 'DELETE' THEN RETURN OLD; ELSE RETURN NEW; END IF;
END; $$;

DO $$
DECLARE
    t text;
BEGIN
    FOREACH t IN ARRAY ARRAY[
        'prices', 'price_rules',
        'users', 'tenants', 'events',
        'bookings', 'booking_lines', 'invitations',
        'event_ticket_types', 'event_tables', 'staff_event_access',
        'stripe_transactions', 'tenant_subscriptions', 'tenant_addons', 'billing_charges'
    ]
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS tr_audit_%I ON %I', t, t);
        EXECUTE format(
            'CREATE TRIGGER tr_audit_%I AFTER INSERT OR UPDATE OR DELETE ON %I FOR EACH ROW EXECUTE FUNCTION fn_audit_trigger()',
            t, t);
    END LOOP;
END $$;
