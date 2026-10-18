set search_path to public;

/*(BR-10) Un restaurant doit avoir au moins un manager.*/

CREATE OR REPLACE FUNCTION check_resto_atleast_one_manager_r_managers()
    RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS(SELECT manager
              FROM restaurant_managers
              WHERE restaurant = old.restaurant AND manager != old.manager) THEN
        RAISE EXCEPTION 'Un restaurant doit toujours avoir au moins un manager.';
    END IF;
    RETURN old;
END;
$$LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_resto_atleast_one_manager_restaurants()
    RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS(SELECT manager
                  FROM restaurant_managers
                  WHERE restaurant = new.id) THEN
        RAISE EXCEPTION 'Un restaurant doit toujours avoir au moins un manager.';
    END IF;
    RETURN null;
END;
$$LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER resto_atleast_one_manager_r_managers
    BEFORE DELETE ON restaurant_managers
    FOR EACH ROW
EXECUTE FUNCTION check_resto_atleast_one_manager_r_managers();

CREATE CONSTRAINT TRIGGER resto_atleast_one_manager_restaurant
    AFTER INSERT ON restaurants
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW
EXECUTE PROCEDURE check_resto_atleast_one_manager_restaurants();