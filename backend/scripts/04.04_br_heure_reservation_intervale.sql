set search_path to public;

/*(BR-04) L'heure d'une réservation confirmée, terminée ou en attente doit être comprise
entre l'heure de début et l'heure de fin d'un service pour le même jour de la semaine.*/

CREATE OR REPLACE FUNCTION check_reservation_intervale()
    RETURNS TRIGGER AS
$$
DECLARE
    _days_of_week INT;
BEGIN
    _days_of_week := EXTRACT(ISODOW FROM NEW.datetime);
    IF NEW.status IN ('pending', 'confirmed', 'completed') THEN
        IF NOT EXISTS (SELECT 1
                       FROM services
                       WHERE restaurant = NEW.restaurant
                         AND day_of_week = _days_of_week
                         AND NEW.datetime::time >= start_time
                         /* l'heure de fin d'un service représente l'heure au-delà de laquelle le restaurant n'accepte plus de clients */
                         AND NEW.datetime::time < end_time
                       ) THEN
            RAISE EXCEPTION '(BR-4): L''heure de la réservation doit être comprise dans un horaire de service valide';
        END IF;

    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- trigger de la modif d'un service
CREATE OR REPLACE FUNCTION check_reservation_intervale_service()
    RETURNS TRIGGER AS
$$
DECLARE
    ligne_reservation RECORD;
    reservation_time TIME;
BEGIN
    FOR ligne_reservation IN
        SELECT r.datetime
        FROM reservations r
        WHERE r.restaurant = old.restaurant
          AND r.status IN ('confirmed', 'completed')
          AND EXTRACT(ISODOW FROM r.datetime) = OLD.day_of_week
          AND r.datetime::time >= OLD.start_time
          AND r.datetime::time < OLD.end_time
    LOOP
        reservation_time := ligne_reservation.datetime::time;
        IF (EXTRACT(ISODOW FROM ligne_reservation.datetime) != NEW.day_of_week
                OR reservation_time < NEW.start_time
                OR reservation_time >= NEW.end_time)
            THEN raise exception '(BR-4): la modification est impossible car des reservations y sont assigné';
        END IF;
    END LOOP;
    RETURN NEW;
end;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_reservation_intervale_service_delete()
    RETURNS TRIGGER AS
$$
begin
    if exists(
        select 1
        from reservations
            join services s on reservations.restaurant = s.restaurant
                                   and s.day_of_week = extract(ISODOW from datetime)
                                   and datetime::time >= s.start_time
                                   and datetime::time < end_time
        where status in ('confirmed', 'completed') and s.restaurant = old.restaurant) then
            raise exception '(BR-4): la suppression est impossible car des reservations y sont assigné';
    end if;

    return old;
end;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_reservation_hour_intervale
    BEFORE INSERT OR UPDATE
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION check_reservation_intervale();

CREATE OR REPLACE TRIGGER trigger_reservation_hour_intervale_service_update
    BEFORE UPDATE of start_time, end_time
    ON services
    FOR EACH ROW
EXECUTE FUNCTION check_reservation_intervale_service();

CREATE OR REPLACE TRIGGER trigger_reservation_hour_intervale_service_delete
    BEFORE DELETE
    ON services
    FOR EACH ROW
EXECUTE FUNCTION check_reservation_intervale_service_delete();

