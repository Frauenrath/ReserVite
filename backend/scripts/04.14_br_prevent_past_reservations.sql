set search_path to public;

/*(BR-14) Une réservation ne peut pas être créée dans le passé (ne doit être vérifié qu'au moment de la création*/

CREATE OR REPLACE FUNCTION  prevent_past_reservation()
RETURNS trigger as $$
    DECLARE currentTime TIMESTAMP;
BEGIN
    SELECT simulated_time INTO currentTime
    FROM system_time
    LIMIT 1;

    IF(currentTime IS NULL OR NEW.datetime < currentTime) THEN
        RAISE EXCEPTION 'BR-14 : Impossible d''ajouter de date dans le pasée';
    END IF;

    RETURN NEW;
END;
$$LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_prevent_past_reservation
    BEFORE INSERT
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION prevent_past_reservation();