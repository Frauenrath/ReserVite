set search_path to public;

/*(BR-07) Pour un même jour de la semaine, les services d'un restaurant ne peuvent pas se chevaucher.*/

CREATE OR REPLACE FUNCTION prevent_same_day_services()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1
               FROM services s
               WHERE new.restaurant = s.restaurant
                 AND s.day_of_week = new.day_of_week
                 AND new.start_time < s.end_time
                 AND s.start_time < NEW.end_time
                 AND s.id <> NEW.id) THEN
      RAISE EXCEPTION 'Les services ne peuvent pas se chevaucher pour un meme jour';
    END IF;
    RETURN NEW;
END;
$$LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_prevent_same_day_services on services;

CREATE TRIGGER trg_prevent_same_day_services
    BEFORE INSERT OR UPDATE ON services
    FOR EACH ROW
EXECUTE FUNCTION prevent_same_day_services();