set search_path to public;

/*(BR-01) Une réservation doit être associée à un utilisateur ayant le rôle de client.*/

CREATE OR REPLACE FUNCTION  check_role_of_user_for_reservations()
    RETURNS trigger as $$
BEGIN
    IF ((SELECT role from users where id = new.client) != 'client') THEN
        RAISE EXCEPTION 'Une réservation doit être associée à un utilisateur ayant le rôle de client.';
    end if;
    RETURN new;
END;
$$LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER client_role_req_for_reservations
    BEFORE INSERT ON reservations
    FOR EACH ROW
EXECUTE FUNCTION check_role_of_user_for_reservations();
