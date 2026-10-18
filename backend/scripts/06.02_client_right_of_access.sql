set search_path to public, auth;
/*
Rappel :
Les Vues :
  Confidentialité / sécurité :
    permettre de restreindre l'accès aux données présentées en masquant certaines lignes / colonnes d'une table.
*/

--#region Access-table-users

-- Table User:

-- READ: ses données
-- CREATE: non
-- UPDATE: non
-- DELETE: non

-- Client a accès seulement à ses données.
create or replace view v_acces_client_on_user as
select users.id, users.email,users.full_name,users.role,users.phone --  On oublie volontairement 'password'.
from users
where (auth.role()='client' and users.id = auth.id());

drop trigger if exists check_client_access_on_users_trigger on users;
drop function if exists check_client_access_on_users();

CREATE OR REPLACE FUNCTION check_client_access_on_users()
    RETURNS TRIGGER AS
$$
begin
    -- Si l'utilisateur n'est pas manager, on ne fait rien.
    if auth.role() != 'client' then
        if tg_op ='DELETE' then
            return old;
        else
            return new;
        end if;
    end if;

    -- Mode Create:
    if tg_op = 'INSERT' then
        raise exception 'Access denied: Client cannot create new user';
        -- Mode Update:
    elsif tg_op = 'UPDATE' then
        raise exception 'Access denied: Client cannot update user';
        -- Mode Delete:
    elsif tg_op = 'DELETE' then
        raise exception 'Access denied: Client cannot delete user';
    end if;

    if tg_op ='DELETE' then
        return old;
    else
        return new;
    end if;
end
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_client_access_on_users_trigger
    BEFORE UPDATE OR DELETE OR INSERT
    ON users
    FOR EACH ROW
EXECUTE FUNCTION check_client_access_on_users();
--#endregion

--#region Access-table-restaurant


-- Table Restaurant:

-- READ: oui
-- CREATE: non
-- UPDATE: non
-- DELETE: non

-- Client a accès à tous les restaurants .
create or replace view v_acces_client_on_restaurants as
select *
from restaurants
where auth.role() = 'client';


drop trigger if exists check_client_access_on_restaurants_trigger on restaurants;
drop function if exists check_client_access_on_restaurants();

CREATE OR REPLACE FUNCTION check_client_access_on_restaurants()
    RETURNS TRIGGER AS
$$
begin
    -- Si l'utilisateur n'est pas manager, on ne fait rien.
    if auth.role() != 'client' then
        if tg_op ='DELETE' then
            return old;
        else
            return new;
        end if;
    end if;

    -- Mode Create:
    if tg_op = 'INSERT' then
        raise exception 'Access denied: Client cannot create new restaurant';
        -- Mode Update:
    elsif tg_op = 'UPDATE' then
        raise exception 'Access denied: Client cannot update restaurant';
        -- Mode Delete:
    elsif tg_op = 'DELETE' then
        raise exception 'Access denied: Client cannot delete restaurant';
    end if;

    if tg_op ='DELETE' then
        return old;
    else
        return new;
    end if;
end
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_client_access_on_restaurants_trigger
    BEFORE UPDATE OR DELETE OR INSERT
    ON restaurants
    FOR EACH ROW
EXECUTE FUNCTION check_client_access_on_restaurants();
--#endregion

--#region Access-table-services

-- Table Services:

-- READ: oui
-- CREATE: non
-- UPDATE: non
-- DELETE: non

create or replace view v_acces_client_on_services as
select *
from services
where auth.role()='client';


drop trigger if exists check_client_access_on_services_trigger on services;
drop function if exists check_client_access_on_services();

CREATE OR REPLACE FUNCTION check_client_access_on_services()
    RETURNS TRIGGER AS
$$
begin
    -- Si l'utilisateur n'est pas manager, on ne fait rien.
    if auth.role() != 'client' then
        if tg_op ='DELETE' then
            return old;
        else
            return new;
        end if;
    end if;

    -- Mode Create:
    if tg_op = 'INSERT' then
        raise exception 'Access denied: Client cannot create new service';
        -- Mode Update:
    elsif tg_op = 'UPDATE' then
        raise exception 'Access denied: Client cannot update service';
        -- Mode Delete:
    elsif tg_op = 'DELETE' then
        raise exception 'Access denied: Client cannot delete service';
    end if;

    if tg_op ='DELETE' then
        return old;
    else
        return new;
    end if;
end
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_client_access_on_services_trigger
    BEFORE UPDATE OR DELETE OR INSERT
    ON services
    FOR EACH ROW
EXECUTE FUNCTION check_client_access_on_services();
--#endregion


--#region Access-table-tables

create or replace view v_acces_client_on_tables as
select *
from tables
where auth.role()='client';


drop trigger if exists check_client_access_on_tables_trigger on tables;
drop function if exists check_client_access_on_tables();

CREATE OR REPLACE FUNCTION check_client_access_on_tables()
    RETURNS TRIGGER AS
$$
begin
    -- Si l'utilisateur n'est pas manager, on ne fait rien.
    if auth.role() != 'client' then
        if tg_op ='DELETE' then
            return old;
        else
            return new;
        end if;
    end if;

    -- Mode Create:
    if tg_op = 'INSERT' then
        raise exception 'Access denied: Client cannot create new table';
        -- Mode Update:
    elsif tg_op = 'UPDATE' then
        raise exception 'Access denied: Client cannot update table';
        -- Mode Delete:
    elsif tg_op = 'DELETE' then
        raise exception 'Access denied: Client cannot delete table';
    end if;

    if tg_op ='DELETE' then
        return old;
    else
        return new;
    end if;
end
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_client_access_on_tables_trigger
    BEFORE UPDATE OR DELETE OR INSERT
    ON tables
    FOR EACH ROW
EXECUTE FUNCTION check_client_access_on_tables();
--#endregion

--#region Access-table-reservations

-- Table Reservations:

-- READ: les siennes + indirectement celles des autres pour vérifier les disponibilités
-- CREATE: pour lui-même
-- UPDATE: les siennes
-- DELETE: non

-- le client ne peut voir que ses réservations,
-- pour voir les autres réservations une fonction spécifique SECURITY DEFINER sera appelée.
-- Le client aura accès aux autres réservations ( pour calculer les heures dipo par exemple)
-- via cette fonction sans qu'il puisse voir les réservations des autres directements.
create or replace view v_acces_client_on_reservations as
select *
from reservations
where (auth.role() = 'client' and reservations.client = auth.id());



drop trigger if exists check_client_access_on_reservations_trigger on reservations;
drop function if exists check_client_access_on_reservations();

CREATE OR REPLACE FUNCTION check_client_access_on_reservations()
    RETURNS TRIGGER AS
$$
declare
    client_id int;
    restaurant_id int;
begin
    -- Si l'utilisateur n'est pas manager, on ne fait rien.
    if auth.role() != 'client' then
        if tg_op ='DELETE' then
            return old;
        else
            return new;
        end if;
    end if;

    if tg_op = 'DELETE' then
        client_id := old.client;
        restaurant_id := old.restaurant;
    else
        client_id := new.client;
        restaurant_id := new.restaurant;
    end if;
    if not exists(
        select 1
        from users
        where users.id = client_id
        and client_id = auth.id()
    )then
        raise exception 'Access denied: The customer must make a reservation at a restaurant in their own name';
    end if;
    if not exists(
        select 1
        from restaurants
        where restaurants.id = restaurant_id
    )then
        raise exception 'Access denied: The customer must make a reservation at a restaurant valid';
    end if;
    -- Mode Create:
    if tg_op = 'INSERT' then
        if (new.client != auth.id())then
            raise exception 'Access denied: The customer must make a reservation in their own name';
        end if;
        -- Mode Update:
    elsif tg_op = 'UPDATE' then
        if(old.client != auth.id()) then
            raise exception 'Access denied: The customer must update a reservation in their own name';
        end if;
        -- Mode Delete:
    elsif tg_op = 'DELETE' then
        raise exception 'Access denied: Client cannot delete a reservation';
    end if;

    if tg_op ='DELETE' then
        return old;
    else
        return new;
    end if;
end
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_client_access_on_reservations_trigger
    BEFORE UPDATE OR DELETE OR INSERT
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION check_client_access_on_reservations();
--#endregion

--#region Access-table-reservation_tables

-- Table Reservation_tables:

-- READ: indirectement pour vérifier les disponibilités
-- CREATE: non
-- UPDATE: N/A
-- DELETE: indirectement quand modifie une de ses réservations confirmée


-- le client ne peut voir que ses réservations,
-- pour voir les autres réservations une fonction spécifique SECURITY DEFINER sera appelée.
-- Le client aura accès aux autres réservations ( pour calculer les heures dipo par exemple)
-- via cette fonction sans qu'il puisse voir les réservations des autres directements.
create or replace view v_acces_client_on_reservation_tables as
select *
from reservation_tables
where (auth.role() = 'client' and reservation_tables.reservation in (
                select reservations.id
                from reservations
                where reservations.client = auth.id()
            )
);


drop trigger if exists check_client_access_on_reservation_tables_trigger on reservation_tables;
drop function if exists check_client_access_on_reservation_tables();

CREATE OR REPLACE FUNCTION check_client_access_on_reservation_tables()
    RETURNS TRIGGER AS
$$
declare
    reservation_id int;
    client_id int;
    status status_type;

begin
    -- Si l'utilisateur n'est pas manager, on ne fait rien.
    if auth.role() != 'client' then
        if tg_op ='DELETE' then
            return old;
        else
            return new;
        end if;
    end if;

    if tg_op = 'DELETE' then
        reservation_id := old.reservation;
    else
        reservation_id := new.reservation;
    end if;

    if not exists(
        select 1
        from reservations
        where reservations.id = reservation_id
    )then
        raise exception 'Access denied: The customer needs to have a table added to an existing reservation';
    end if;
    -- Mode Create:
    if tg_op = 'INSERT' then
        raise exception 'Access denied: The customer must make a reservation in their own name';
    elsif tg_op = 'UPDATE' then
            raise exception 'Access denied: The customer canon update a reservation in their own name';
        -- Mode Delete:
    elsif tg_op = 'DELETE' then
        select reservations.client, reservations.status into  client_id,status
        from reservations
        where reservations.id = reservation_id;
        if(client_id != auth.id())then
            raise exception 'Access denied: Client cannot delete a table from another customer''s reservation';
        end if;
        if status != 'confirmed'::status_type then
            raise exception 'Access denied: Tables can only be removed from a confirmed reservation';
        end if;
    end if;

    if tg_op ='DELETE' then
        return old;
    else
        return new;
    end if;
end
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_client_access_on_reservation_tables_trigger
    BEFORE DELETE OR INSERT OR UPDATE
    ON reservation_tables
    FOR EACH ROW
EXECUTE FUNCTION check_client_access_on_reservation_tables();
--#endregion


--#region Access-table-restaurant_managers

-- Table Restaurant_managers:

-- READ: non
-- CREATE: non
-- UPDATE: N/A
-- DELETE: non

-- Le client  n'a aucun accès en lecture.
create or replace view v_acces_client_on_restaurant_managers as
select *
from restaurant_managers
where false; -- Pour s'assurer que la vue ne renvoie rien.


drop trigger if exists check_client_access_on_restaurant_managers_trigger on  restaurant_managers;
drop function if exists check_client_access_on_restaurant_managers();

CREATE OR REPLACE FUNCTION check_client_access_on_restaurant_managers()
    RETURNS TRIGGER AS
$$

begin
    -- Si l'utilisateur n'est pas client, on ne fait rien.
    if auth.role() != 'client' then
        if tg_op ='DELETE' then
            return old;
        else
            return new;
        end if;
    end if;

    -- Mode Create:
    if tg_op = 'INSERT' then
        raise exception 'Access denied: The customer cannot add a restaurant manager';
    -- Mode Update:
    elsif tg_op = 'UPDATE' then
        raise exception 'Access denied: The customer cannot update a restaurant manager';
        -- Mode Delete:
    elsif tg_op = 'DELETE' then
        raise exception 'Access denied: The customer cannot delete a restaurant manager';
    end if;

    if tg_op ='DELETE' then
        return old;
    else
        return new;
    end if;
end
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_client_access_on_restaurant_managers_trigger
    BEFORE DELETE OR UPDATE OR INSERT
    ON restaurant_managers
    FOR EACH ROW
EXECUTE FUNCTION check_client_access_on_restaurant_managers();
--#endregion

--#region Access-table-system_time

-- Table Date simulée:

-- READ: oui
-- CREATE: non
-- UPDATE: oui
-- DELETE: non

-- Le client a accès en lecture.
create or replace view v_acces_client_on_system_time as
select *
from system_time
where auth.role() = 'client';

drop trigger if exists check_client_access_on_system_time_trigger on system_time;
drop function if exists check_client_access_on_system_time();

CREATE OR REPLACE FUNCTION check_client_access_on_system_time()
    RETURNS TRIGGER AS
$$
begin
    -- Si l'utilisateur n'est pas client, on ne fait rien.
    if auth.role() != 'client' then
        if tg_op ='DELETE' then
            return old;
        else
            return new;
        end if;
    end if;

    -- Le manager ne peut ni créer, ni supprimer la date. Mais il peut la modifier (UPDATE: oui).
    if tg_op = 'INSERT' then
        raise exception 'Access denied: Client cannot create system time.';
    elsif tg_op = 'DELETE' then
        raise exception 'Access denied: Client cannot delete system time.';
    end if;

    if tg_op ='DELETE' then
        return old;
    else
        return new;
    end if;
end
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_client_access_on_system_time_trigger
    BEFORE UPDATE OR DELETE OR INSERT
    ON system_time
    FOR EACH ROW
EXECUTE FUNCTION check_client_access_on_system_time();
--#endregion