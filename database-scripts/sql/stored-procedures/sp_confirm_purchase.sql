CREATE OR REPLACE FUNCTION sp_confirm_booking(p_booking_id uuid, p_qr_token text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER
    SET search_path = public, extensions, pg_catalog
AS $$
DECLARE v_tenant uuid; v_event uuid;
BEGIN
    UPDATE bookings SET status = 'Paid', qr_token = p_qr_token,
        hold_expires_at = NULL, updated_at = now()
    
    
    WHERE bookings_id = p_booking_id AND status IN ('Pending', 'Expired')
    RETURNING tenants_id, events_id INTO v_tenant, v_event;

    IF NOT FOUND THEN
        
        RETURN;
    END IF;

    UPDATE tables SET status = 'Booked', locked_by_users_id = NULL,
        lock_expires_at = NULL, updated_at = now()
    WHERE tables_id IN (SELECT tables_id FROM booking_lines WHERE bookings_id = p_booking_id AND kind = 'Table')
      AND status IN ('Locked', 'Available');
END; $$;
