CREATE OR REPLACE FUNCTION sp_upsert_tax_rate(
    p_zip text, p_state text, p_county text, p_city text,
    p_state_rate numeric, p_county_rate numeric, p_city_rate numeric,
    p_local_rate numeric, p_combined_rate numeric, p_api_response_id text
) RETURNS void LANGUAGE sql
    SET search_path = public, extensions, pg_catalog
AS $$
    INSERT INTO tax_rate_cache (zip_code, state, county, city, state_rate, county_rate,
        city_rate, local_rate, combined_rate, api_response_id, fetched_at, updated_at)
    VALUES (p_zip, p_state, p_county, p_city,
        COALESCE(p_state_rate, 0), COALESCE(p_county_rate, 0), COALESCE(p_city_rate, 0),
        COALESCE(p_local_rate, 0), COALESCE(p_combined_rate, 0), p_api_response_id, now(), now())
    ON CONFLICT (zip_code) DO UPDATE SET
        state = EXCLUDED.state, county = EXCLUDED.county, city = EXCLUDED.city,
        state_rate = EXCLUDED.state_rate, county_rate = EXCLUDED.county_rate,
        city_rate = EXCLUDED.city_rate, local_rate = EXCLUDED.local_rate,
        combined_rate = EXCLUDED.combined_rate, api_response_id = EXCLUDED.api_response_id,
        fetched_at = now(), updated_at = now();
$$;
