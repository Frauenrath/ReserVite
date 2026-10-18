set search_path to public;

/*(BR-08) Au moment de leur création ou de leur modification,
les heures de début et de fin d'un service doivent être alignées
sur les créneaux de réservation pour le restaurant.*/

CREATE OR REPLACE FUNCTION prevent_start_or_end_time_reservations()
RETURNS TRIGGER AS $$
    declare duration INT;
BEGIN
    SELECT r.slot_duration INTO duration
    FROM restaurants r
    WHERE id = new.restaurant;

    IF duration IS NULL THEN
        RAISE EXCEPTION 'BR-08 Slot de réservation du restaurant introuvable';
    END IF;

    IF  MOD( extract(minute from new.start_time)::int, duration ) !=0 THEN
        RAISE EXCEPTION 'BR-08 L''heure de début % n''est pas alignée sur les créneaux de % min.',
        NEW.start_time, duration;
    END IF;

    IF  MOD( extract(minute from NEW.end_time)::int, duration ) !=0 THEN
        RAISE EXCEPTION 'BR-08 L''heure de fin % n''est pas alignée sur les créneaux de % min',
        NEW.end_time, duration;
    END IF;

RETURN NEW;
END;
$$LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_prevent_start_or_end_time_reservations on services;

CREATE TRIGGER trg_prevent_start_or_end_time_reservations
    BEFORE INSERT OR UPDATE ON services
    FOR EACH ROW
EXECUTE FUNCTION prevent_start_or_end_time_reservations();