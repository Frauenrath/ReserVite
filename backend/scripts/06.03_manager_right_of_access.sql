set search_path to public, auth;
/*
Rappel :
Les Vues :
  Confidentialité / sécurité :
    permettre de restreindre l'accès aux données présentées en masquant certaines lignes / colonnes d'une table.
*/

--#region Access-table-users

-- Table Restaurant:

-- READ: ses données et celles des clients qui ont réservé pour ses restaurants
-- CREATE: non
-- UPDATE: non
-- DELETE: non

-- Manager a accès ses données et celles des clients qui ont réservé pour ses restaurants.
create or replace view v_acces_manager_on_users as
select users.id, users.email,users.full_name,users.role,users.phone --  On oublie volontairement 'password'.
from users
where ( auth.role() = 'manager' and (
        id = auth.id() -- les donéns du manager connecté.
                or id in ( -- Les données des users clients des restaurants géré par le manager.
                select client
                from reservations
                where restaurant in (select restaurant from restaurant_managers where manager = auth.id())
            )
        )
      );


drop trigger if exists check_manager_access_on_users_trigger on users;
drop function if exists check_manager_access_on_users();

CREATE OR REPLACE FUNCTION check_manager_access_on_users()
    RETURNS TRIGGER AS
$$
begin
    -- Si l'utilisateur n'est pas manager, on ne fait rien.
    if auth.role() != 'manager' then
        if tg_op ='DELETE' then
            return old;
        else
            return new;
        end if;
    end if;

    -- Mode Create:
    if tg_op = 'INSERT' then
        raise exception 'Access denied: Manager cannot create new user';
        -- Mode Update:
    elsif tg_op = 'UPDATE' then
        raise exception 'Access denied: Manager cannot update user';
        -- Mode Delete:
    elsif tg_op = 'DELETE' then
        raise exception 'Access denied: Manager cannot delete user';
    end if;

    if tg_op ='DELETE' then
        return old;
    else
        return new;
    end if;
end
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_manager_access_on_users_trigger
    BEFORE UPDATE OR DELETE OR INSERT
    ON users
    FOR EACH ROW
EXECUTE FUNCTION check_manager_access_on_users();

--#endregion

--#region Access-table-restaurant

-- Table Restaurant:

-- READ: pour ses restaurants
-- CREATE: non
-- UPDATE: non
-- DELETE: non

-- Manager a accès seulement à ses restaurants.
create or replace view v_acces_manager_on_restaurant as
select *
from restaurants
where (auth.role() ='manager' and restaurants.id in (
            select restaurant_managers.restaurant
            from restaurant_managers
            where restaurant_managers.manager = auth.id()
        )
      );


drop trigger if exists  check_manager_access_on_restaurants_trigger on restaurants;
drop function if exists  check_manager_access_on_restaurants();

CREATE OR REPLACE FUNCTION  check_manager_access_on_restaurants()
    RETURNS TRIGGER AS
$$
begin
    -- Si l'utilisateur n'est pas manager, on ne fait rien.
    if auth.role() != 'manager' then
        if tg_op ='DELETE' then
            return old;
        else
            return new;
        end if;
    end if;

    -- Mode Create:
    if tg_op = 'INSERT' then
        raise exception 'Access denied: Manager cannot create new restaurant';
        -- Mode Update:
    elsif tg_op = 'UPDATE' then
        raise exception 'Access denied: Manager cannot update restaurant';
        -- Mode Delete:
    elsif tg_op = 'DELETE' then
        raise exception 'Access denied: Manager cannot delete restaurant';
    end if;

    if tg_op ='DELETE' then
        return old;
    else
        return new;
    end if;
end
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER  check_manager_access_on_restaurants_trigger
    BEFORE UPDATE OR DELETE OR INSERT
    ON restaurants
    FOR EACH ROW
EXECUTE FUNCTION  check_manager_access_on_restaurants();
--#endregion

--#region Access-table-service


-- Table Service:

-- READ: pour ses restaurants
-- CREATE: pour ses restaurants
-- UPDATE: pour ses restaurants
-- DELETE: pour ses restaurants

-- Manager a accès seulement aux services de ses restaurants.
create or replace view v_acces_manager_on_services as
select *
from services
where (auth.role() ='manager' and services.restaurant in (
    select restaurant_managers.restaurant
    from restaurant_managers
    where restaurant_managers.manager = auth.id()
)
          );


drop trigger if exists  check_manager_access_on_services_trigger on services;
drop function if exists  check_manager_access_on_services();

CREATE OR REPLACE FUNCTION check_manager_access_on_services()
    RETURNS TRIGGER AS
$$
declare
--     -- la liste d'entiers (tableau vide au départ).
--     liste_restaurant_ids INT[] := ARRAY[]::INT[];
--     restaurant_id INT;
    restaurant_id INT;
begin
    --     -- Boucle pour remplir la liste avec les IDs issus de la requête.
--     FOR restaurant_id IN SELECT restaurant FROM restaurant_managers WHERE restaurant_managers.manager = auth.id() LOOP
--             -- Ajout de l'entier dans le tableau.
--         liste_restaurant_ids := ARRAY_APPEND(liste_restaurant_ids, restaurant_id);
--         END LOOP;

    -- Si l'utilisateur n'est pas manager, on ne fait rien.
    if auth.role() != 'manager' then
        if tg_op ='DELETE' then
            return old;
        else
            return new;
        end if;
    end if;

    if tg_op ='DELETE' then
        restaurant_id := old.restaurant;
    else
        restaurant_id := new.restaurant;
    end if;

    if not exists(
        select 1
        from restaurant_managers
        where restaurant_managers.manager = auth.id()
          and restaurant_managers.restaurant = restaurant_id
    ) then
        raise exception 'Access denied: You do not manage the restaurant (ID %) associated with this service.', restaurant_id;
    end if;

    if tg_op ='DELETE' then
        return old;
    else
        return new;
    end if;
end
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_manager_access_on_services_trigger
    BEFORE UPDATE OR DELETE OR INSERT
    ON services
    FOR EACH ROW
EXECUTE FUNCTION  check_manager_access_on_services();
--#endregion


--#region Access-table-tables

-- Table Tables:

-- READ: pour ses restaurants
-- CREATE: pour ses restaurants
-- UPDATE: pour ses restaurants
-- DELETE: non

-- Manager a accès seulement aux tables de ses restaurants.
create or replace view v_acces_manager_on_tables as
select *
from tables
where (auth.role() ='manager' and tables.restaurant in (
    select restaurant_managers.restaurant
    from restaurant_managers
    where restaurant_managers.manager = auth.id()
)
          );

drop trigger if exists  check_manager_access_on_tables_trigger on tables;
drop function if exists  check_manager_access_on_tables();

CREATE OR REPLACE FUNCTION check_manager_access_on_tables()
    RETURNS TRIGGER AS
$$
begin
    -- Si l'utilisateur n'est pas manager, on ne fait rien.
    if auth.role() != 'manager' then
        if tg_op ='DELETE' then
            return old;
        else
            return new;
        end if;
    end if;

    if tg_op ='INSERT' or tg_op ='UPDATE' then
        if not exists(
            select 1
            from restaurant_managers
            where (
                      restaurant_managers.manager = auth.id()
                          and restaurant_managers.restaurant = new.restaurant
                      )
        ) then
            raise exception 'Access denied: You cannot manage a table that is not associated with one of your restaurants.';
        end if;
    end if;

    if tg_op ='DELETE' then
        raise exception 'Access denied: Manager cannot delete tables';
    end if;

    return new;
end
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_manager_access_on_tables_trigger
    BEFORE UPDATE OR DELETE OR INSERT
    ON tables
    FOR EACH ROW
EXECUTE FUNCTION  check_manager_access_on_tables();
--#endregion

--#region Access-table-reservations

-- Manager a accès seulement aux réservations de ses restaurants.

-- Table Réservation:

-- READ: pour ses restaurants
-- CREATE: non
-- UPDATE: le status, pour ses restaurants
-- DELETE: non
create or replace view v_acces_manager_on_reservations as
select *
from reservations
where (auth.role() ='manager' and reservations.restaurant in (
            select restaurant_managers.restaurant
            from restaurant_managers
            where restaurant_managers.manager = auth.id()
        )
);

drop trigger if exists  check_manager_access_on_reservations_trigger on reservations;
drop function if exists  check_manager_access_on_reservations();

CREATE OR REPLACE FUNCTION check_manager_access_on_reservations()
    RETURNS TRIGGER AS
$$
begin
    -- Si l'utilisateur n'est pas manager, on ne fait rien.
    if auth.role() != 'manager' then
        if tg_op ='DELETE' then
            return old;
        else
            return new;
        end if;
    end if;

    if tg_op ='INSERT' or tg_op ='DELETE' then
        raise exception 'Access denied: You cannot create or delete reservations.';
    end if;
    if tg_op ='UPDATE' then
        if not exists(
            select 1
            from restaurant_managers
            where restaurant_managers.manager = auth.id()
            and restaurant_managers.restaurant = new.restaurant
        )then
            raise exception 'Access denied: You do not manage the reservation (ID %) of this restaurant (ID %).', new.id,new.restaurant;
        end if;
        -- Vérifier que SEUL le statut est modifié (et que les autres champs sont identiques).
        IF (new.client, new.restaurant, new.datetime, new.number_of_guests, new.special_requests)
            IS DISTINCT FROM
           (old.client, old.restaurant, old.datetime, old.number_of_guests, old.special_requests)
        THEN
            raise exception 'Access denied: Managers can only update the status of a reservation.';
        end if;
    end if;

    return new;
end
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_manager_access_on_reservations_trigger
    BEFORE UPDATE OR DELETE OR INSERT
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION  check_manager_access_on_reservations();
--#endregion

--#region Access-table-reservation_tables

-- Tables d'une réservation:

-- READ: pour ses restaurants
-- CREATE: pour ses restaurants
-- UPDATE: N/A
-- DELETE: pour ses restaurants

-- Manager a accès seulement aux Tables de réservation de ses restaurants.
create or replace view v_acces_manager_on_reservation_tables as
select *
from reservation_tables
where (auth.role() ='manager' and reservation_tables."table" in (
            select tables.id
            from tables
            where tables.restaurant in (
                select restaurant_managers.restaurant
                from restaurant_managers
                where restaurant_managers.manager = auth.id()
            )
      )
);


drop trigger if exists  check_manager_access_on_reservation_tables_trigger on reservation_tables;
drop function if exists  check_manager_access_on_reservation_tables();

CREATE OR REPLACE FUNCTION check_manager_access_on_reservation_tables()
    RETURNS TRIGGER AS
$$
begin
    -- Si l'utilisateur n'est pas manager, on ne fait rien.
    if auth.role() != 'manager' then
        if tg_op ='DELETE' then
            return old;
        else
            return new;
        end if;
    end if;

    /*
    Peux ajouter une table à une réservation, mais seulement si cette réservation
    (à laquelle on ajoute une table) appartient à un restaurant qu'on gère.
     */
    if tg_op ='INSERT'then
        if not exists(
            select 1
            from  reservations
            where reservations.restaurant in (
                select restaurant_managers.restaurant
                from restaurant_managers
                where restaurant_managers.manager = auth.id()
            )
              and reservations.id = new.reservation
        )then
            raise exception 'Access denied: Managers can only create new reservation''s tables for your restaurants.';
        end if;
    end if;

    /*
    Peux supprimer une table d'une réservation, mais seulement si cette réservation
    appartient à un restaurant qu'on gère.
     */
    if tg_op ='DELETE' then
        if not exists(
            select 1
            from  reservations
            where reservations.restaurant in (
                select restaurant_managers.restaurant
                from restaurant_managers
                where restaurant_managers.manager = auth.id()
            )
              and reservations.id = old.reservation
        )then
            raise exception 'Access denied: Managers can only delete table assignments from reservations of your restaurants.';
        end if;
    end if;

    if tg_op ='UPDATE'then
        raise exception 'Access denied: Managers can only update table assignments from reservations of your restaurants.';
    end if;
    if tg_op ='DELETE' then
        return old;
    else
        return new;
    end if;
end
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_manager_access_on_reservation_tables_trigger
    BEFORE DELETE OR INSERT OR UPDATE
    ON reservation_tables
    FOR EACH ROW
EXECUTE FUNCTION  check_manager_access_on_reservation_tables();
--#endregion

--#region Access-table-restaurant_managers

-- Managers d'un restaurant:

-- READ: non
-- CREATE: non
-- UPDATE: N/A
-- DELETE: non

-- Le manager n'a aucun accès en lecture.
create or replace view v_acces_manager_on_restaurant_managers as
select *
from restaurant_managers
where false; -- Pour s'assurer que la vue ne renvoie rien.

drop trigger if exists check_manager_access_on_restaurant_managers_trigger on restaurant_managers;
drop function if exists check_manager_access_on_restaurant_managers();

CREATE OR REPLACE FUNCTION check_manager_access_on_restaurant_managers()
    RETURNS TRIGGER AS
$$
begin
    -- Si l'utilisateur n'est pas manager, on ne fait rien.
    if auth.role() != 'manager' then
        if tg_op ='DELETE' then
            return old;
        else
            return new;
        end if;
    end if;

    -- Le manager ne peut ni créer, ni modifier, ni supprimer des managers.
    if tg_op = 'INSERT' then
        raise exception 'Access denied: Manager cannot create managers to a restaurant.';
    elsif tg_op = 'UPDATE' then
        raise exception 'Access denied: Manager cannot update restaurant managers.';
    elsif tg_op = 'DELETE' then
        raise exception 'Access denied: Manager cannot delete restaurant managers.';
    end if;

    if tg_op ='DELETE' then
        return old;
    else
        return new;
    end if;
end
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_manager_access_on_restaurant_managers_trigger
    BEFORE UPDATE OR DELETE OR INSERT
    ON restaurant_managers
    FOR EACH ROW
EXECUTE FUNCTION check_manager_access_on_restaurant_managers();
--#endregion

--#region Access-table-system_time

-- Table Date simulée:

-- READ: oui
-- CREATE: non
-- UPDATE: oui
-- DELETE: non

-- Le manager a accès en lecture.
create or replace view v_acces_manager_on_system_time as
select *
from system_time
where auth.role() = 'manager';

drop trigger if exists check_manager_access_on_system_time_trigger on system_time;
drop function if exists check_manager_access_on_system_time();

CREATE OR REPLACE FUNCTION check_manager_access_on_system_time()
    RETURNS TRIGGER AS
$$
begin
    -- Si l'utilisateur n'est pas manager, on ne fait rien.
    if auth.role() != 'manager' then
        if tg_op ='DELETE' then
            return old;
        else
            return new;
        end if;
    end if;

    -- Le manager ne peut ni créer, ni supprimer la date. Mais il peut la modifier (UPDATE: oui).
    if tg_op = 'INSERT' then
        raise exception 'Access denied: Manager cannot create system time.';
    elsif tg_op = 'DELETE' then
        raise exception 'Access denied: Manager cannot delete system time.';
    end if;

    if tg_op ='DELETE' then
        return old;
    else
        return new;
    end if;
end
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_manager_access_on_system_time_trigger
    BEFORE UPDATE OR DELETE OR INSERT
    ON system_time
    FOR EACH ROW
EXECUTE FUNCTION check_manager_access_on_system_time();
--#endregion