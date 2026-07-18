





CREATE OR REPLACE FUNCTION app.tier_pricing(p_tier text)
RETURNS TABLE(monthly_cents int, percent_bps int, flat_cents int)
LANGUAGE sql IMMUTABLE
SET search_path = public, extensions, pg_catalog
AS $$
    SELECT t.monthly_cents, t.percent_bps, t.flat_cents FROM (VALUES
        ('free',             0, 650, 175),
        ('trial',            0, 550, 150),
        ('suspended',        0, 650, 175),
        ('starter',       4900, 600, 150),
        ('professional',  9900, 550, 150),
        ('business',     19900, 500, 125),
        ('enterprise',   39900, 450, 125)
    ) AS t(tier, monthly_cents, percent_bps, flat_cents)
    WHERE t.tier = p_tier;
$$;


CREATE OR REPLACE FUNCTION app.event_tier_pricing(p_tier text)
RETURNS TABLE(price_cents int, percent_bps int, flat_cents int,
              sms_credits int, custom_domain_limit int)
LANGUAGE sql IMMUTABLE
SET search_path = public, extensions, pg_catalog
AS $$
    SELECT t.price_cents, t.percent_bps, t.flat_cents, t.sms_credits, t.custom_domain_limit FROM (VALUES
        ('starter_event',     2500, 600, 150,    0, 0),
        ('pro_event',         4900, 550, 150,    0, 1),
        ('business_event',    9900, 500, 125,  500, 2),
        ('enterprise_event', 19900, 450, 125, 2500, 2)
    ) AS t(tier, price_cents, percent_bps, flat_cents, sms_credits, custom_domain_limit)
    WHERE t.tier = p_tier;
$$;


CREATE OR REPLACE FUNCTION app.addon_pricing(p_type text)
RETURNS TABLE(monthly_cents int, annual_cents int, setup_fee_cents int)
LANGUAGE sql IMMUTABLE
SET search_path = public, extensions, pg_catalog
AS $$
    SELECT t.monthly_cents, t.annual_cents, t.setup_fee_cents FROM (VALUES
        ('custom_domain',      2000, 20000, 39900),
        ('advanced_analytics', 2900, 29000,     0),
        ('sms',                2500, 25000,     0),
        ('extra_manager',      1000, 10000,     0)
    ) AS t(type, monthly_cents, annual_cents, setup_fee_cents)
    WHERE t.type = p_type;
$$;



CREATE OR REPLACE FUNCTION app.assert_tenant_sellable(p_tenant uuid)
RETURNS void
LANGUAGE plpgsql STABLE
SET search_path = public, extensions, pg_catalog
AS $$
BEGIN
    IF (SELECT tier FROM tenants WHERE tenants_id = p_tenant) = 'suspended' THEN
        RAISE EXCEPTION 'This organizer account is suspended.' USING ERRCODE = 'P0001';
    END IF;
END; $$;




DROP FUNCTION IF EXISTS app.ensure_tier_formula(text, int, int, int);

CREATE OR REPLACE FUNCTION app.ensure_tier_formula(p_name text, p_percent_bps int, p_flat_cents int)
RETURNS uuid
LANGUAGE plpgsql
SET search_path = public, extensions, pg_catalog
AS $$
DECLARE v_id uuid;
BEGIN
    SELECT fee_formulas_id INTO v_id FROM fee_formulas WHERE name = p_name;
    IF FOUND THEN
        UPDATE fee_formulas
           SET percent_bps = p_percent_bps, flat_cents = p_flat_cents,
               is_active = true, updated_at = now()
         WHERE fee_formulas_id = v_id
           AND (percent_bps <> p_percent_bps OR flat_cents <> p_flat_cents OR is_active = false);
        RETURN v_id;
    END IF;
    INSERT INTO fee_formulas (fee_formulas_id, name, percent_bps, flat_cents,
        max_fee_cents, is_active, created_at, updated_at)
    VALUES (gen_random_uuid(), p_name, p_percent_bps, p_flat_cents, NULL, true, now(), now())
    RETURNING fee_formulas_id INTO v_id;
    RETURN v_id;
END; $$;
