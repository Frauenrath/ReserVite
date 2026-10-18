set search_path to public;

/*(BR-03) Les tables associées à une réservation doivent appartenir au restaurant de la réservation.*/

CREATE OR REPLACE FUNCTION  check_reservation_tables_id_restaurant_match_id_table()
    RETURNS TRIGGER AS $$

DECLARE id_rest_table int ;
DECLARE id_rest_reservation int;
BEGIN
    SELECT restaurant INTO id_rest_table
    FROM tables
    WHERE id = new.table;

    SELECT restaurant INTO id_rest_reservation
    FROM reservations
    WHERE id = new.reservation;

    IF (id_rest_reservation != id_rest_table) THEN
        RAISE EXCEPTION 'Les tables associées à une réservation doivent appartenir au restaurant de la réservation.';
    END IF;
    RETURN new;
END;
$$LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER reservation_tables_id_restaurant_match_id_table
    BEFORE INSERT ON reservation_tables
    FOR EACH ROW
EXECUTE FUNCTION check_reservation_tables_id_restaurant_match_id_table();
