CREATE OR REPLACE FUNCTION sp_delete_table(p_id uuid)
RETURNS void LANGUAGE plpgsql
    SET search_path = public, extensions, pg_catalog
AS $$
BEGIN
    IF EXISTS(
        SELECT 1 FROM tables
        WHERE tables_id = p_id
          AND (status = 'Booked' OR (status = 'Locked' AND lock_expires_at > now()))
    ) THEN
        RAISE EXCEPTION 'This table has been sold or is currently held and cannot be deleted.';
    END IF;
    DELETE FROM tables WHERE tables_id = p_id;
END; $$;
