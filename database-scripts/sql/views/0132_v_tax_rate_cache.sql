CREATE OR REPLACE VIEW vw_tax_rate_cache AS
SELECT zip_code, state, county, city, state_rate, county_rate, city_rate,
       local_rate, combined_rate, api_response_id, fetched_at, updated_at
FROM tax_rate_cache;
