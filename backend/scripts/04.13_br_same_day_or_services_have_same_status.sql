set search_path to public;

/*(BR-13) Un client ne peut pas avoir deux réservations en attente, confirmées ou terminées pour une même date et un même service.*/

CREATE OR REPLACE FUNCTION  check_same_day_or_services_have_same_status()
    RETURNS TRIGGER AS $$

BEGIN
    IF (new.status != 'cancelled') THEN
        IF EXISTS(SELECT 1
                  FROM reservations r
                  JOIN services s on r.restaurant = s.restaurant
                  WHERE r.client = new.client
                    AND r.restaurant = new.restaurant
                    AND r.datetime::date = new.datetime::date
                    AND r.status != 'cancelled'
                    AND r.id != new.id
                    AND s.day_of_week = EXTRACT(ISODOW FROM new.datetime)
                    AND new.datetime::time BETWEEN s.start_time AND s.end_time
                    AND r.datetime:: time BETWEEN  s.start_time ANd s.end_time) THEN
            RAISE EXCEPTION 'BR-13 Le client a déjà une réservation pour ce service ce jour-la.';
        END IF;
    END IF;
    RETURN new;
END;
$$LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER reserv_same_day_or_services_have_same_status
    BEFORE INSERT OR UPDATE ON reservations
    FOR EACH ROW
EXECUTE FUNCTION check_same_day_or_services_have_same_status();
