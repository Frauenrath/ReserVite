set search_path to public, auth;

--#region Access-table-users

-- Table User:

-- READ: indirectement au login (vérification email/mot de passe) et au signup (vérification unicité email et nom)
-- CREATE: au signup
-- UPDATE: non
-- DELETE: non

-- Le visiteur n'a pas accès direct en lecture.
create or replace view v_acces_visitor_on_users as
select *
from users
where false;


drop trigger if exists check_visitor_access_on_users_trigger on users;
drop function if exists check_visitor_access_on_users();

CREATE OR REPLACE FUNCTION check_visitor_access_on_users()
    RETURNS TRIGGER AS
$$
begin
    -- Si le rôle actif n'est pas 'anon', ce n'est pas un visiteur, on ne fait rien.
    if current_user != 'anon' then
        if tg_op ='DELETE' then
            return old;
        else
            return new;
        end if;
    end if;

    -- Mode Create:
    if tg_op = 'INSERT' then
        -- Le visiteur peut créer un utilisateur uniquement via la procédure de signup (security definer).
        -- Si current_user est 'anon', cela signifie que l'insertion est tentée en direct.
        if current_user = 'anon' then
            raise exception 'Access denied: Visitor can only create user through signup';
        end if;
        -- Mode Update:
    elsif tg_op = 'UPDATE' then
        raise exception 'Access denied: Visitor cannot update user';
        -- Mode Delete:
    elsif tg_op = 'DELETE' then
        raise exception 'Access denied: Visitor cannot delete user';
    end if;

    if tg_op ='DELETE' then
        return old;
    else
        return new;
    end if;
end
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_visitor_access_on_users_trigger
    BEFORE UPDATE OR DELETE OR INSERT
    ON users
    FOR EACH ROW
EXECUTE FUNCTION check_visitor_access_on_users();
--#endregion

--#region Access-table-restaurants

-- Table Restaurant:

-- READ: non
-- CREATE: non
-- UPDATE: non
-- DELETE: non

create or replace view v_acces_visitor_on_restaurants as
select *
from restaurants
where false;


drop trigger if exists check_visitor_access_on_restaurants_trigger on restaurants;
drop function if exists check_visitor_access_on_restaurants();

CREATE OR REPLACE FUNCTION check_visitor_access_on_restaurants()
    RETURNS TRIGGER AS
$$
begin
    if current_user != 'anon' then
        if tg_op ='DELETE' then
            return old;
        else
            return new;
        end if;
    end if;

    if tg_op = 'INSERT' then
        raise exception 'Access denied: Visitor cannot create restaurant';
    elsif tg_op = 'UPDATE' then
        raise exception 'Access denied: Visitor cannot update restaurant';
    elsif tg_op = 'DELETE' then
        raise exception 'Access denied: Visitor cannot delete restaurant';
    end if;

    if tg_op ='DELETE' then
        return old;
    else
        return new;
    end if;
end
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_visitor_access_on_restaurants_trigger
    BEFORE UPDATE OR DELETE OR INSERT
    ON restaurants
    FOR EACH ROW
EXECUTE FUNCTION check_visitor_access_on_restaurants();
--#endregion

--#region Access-table-services

-- Table Services:

-- READ: non
-- CREATE: non
-- UPDATE: non
-- DELETE: non

create or replace view v_acces_visitor_on_services as
select *
from services
where false;


drop trigger if exists check_visitor_access_on_services_trigger on services;
drop function if exists check_visitor_access_on_services();

CREATE OR REPLACE FUNCTION check_visitor_access_on_services()
    RETURNS TRIGGER AS
$$
begin
    if current_user != 'anon' then
        if tg_op ='DELETE' then
            return old;
        else
            return new;
        end if;
    end if;

    if tg_op = 'INSERT' then
        raise exception 'Access denied: Visitor cannot create service';
    elsif tg_op = 'UPDATE' then
        raise exception 'Access denied: Visitor cannot update service';
    elsif tg_op = 'DELETE' then
        raise exception 'Access denied: Visitor cannot delete service';
    end if;

    if tg_op ='DELETE' then
        return old;
    else
        return new;
    end if;
end
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_visitor_access_on_services_trigger
    BEFORE UPDATE OR DELETE OR INSERT
    ON services
    FOR EACH ROW
EXECUTE FUNCTION check_visitor_access_on_services();
--#endregion

--#region Access-table-tables

-- Table Tables:

-- READ: non
-- CREATE: non
-- UPDATE: non
-- DELETE: non

create or replace view v_acces_visitor_on_tables as
select *
from tables
where false;


drop trigger if exists check_visitor_access_on_tables_trigger on tables;
drop function if exists check_visitor_access_on_tables();

CREATE OR REPLACE FUNCTION check_visitor_access_on_tables()
    RETURNS TRIGGER AS
$$
begin
    if current_user != 'anon' then
        if tg_op ='DELETE' then
            return old;
        else
            return new;
        end if;
    end if;

    if tg_op = 'INSERT' then
        raise exception 'Access denied: Visitor cannot create table';
    elsif tg_op = 'UPDATE' then
        raise exception 'Access denied: Visitor cannot update table';
    elsif tg_op = 'DELETE' then
        raise exception 'Access denied: Visitor cannot delete table';
    end if;

    if tg_op ='DELETE' then
        return old;
    else
        return new;
    end if;
end
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_visitor_access_on_tables_trigger
    BEFORE UPDATE OR DELETE OR INSERT
    ON tables
    FOR EACH ROW
EXECUTE FUNCTION check_visitor_access_on_tables();
--#endregion

--#region Access-table-reservations

-- Table Reservations:

-- READ: non
-- CREATE: non
-- UPDATE: non
-- DELETE: non

create or replace view v_acces_visitor_on_reservations as
select *
from reservations
where false;



drop trigger if exists check_visitor_access_on_reservations_trigger on reservations;
drop function if exists check_visitor_access_on_reservations();

CREATE OR REPLACE FUNCTION check_visitor_access_on_reservations()
    RETURNS TRIGGER AS
$$
begin
    if current_user != 'anon' then
        if tg_op ='DELETE' then
            return old;
        else
            return new;
        end if;
    end if;

    if tg_op = 'INSERT' then
        raise exception 'Access denied: Visitor cannot create reservation';
    elsif tg_op = 'UPDATE' then
        raise exception 'Access denied: Visitor cannot update reservation';
    elsif tg_op = 'DELETE' then
        raise exception 'Access denied: Visitor cannot delete reservation';
    end if;

    if tg_op ='DELETE' then
        return old;
    else
        return new;
    end if;
end
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_visitor_access_on_reservations_trigger
    BEFORE UPDATE OR DELETE OR INSERT
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION check_visitor_access_on_reservations();
--#endregion

--#region Access-table-reservation_tables

-- Table Reservation_tables:

-- READ: non
-- CREATE: non
-- UPDATE: N/A
-- DELETE: non

create or replace view v_acces_visitor_on_reservation_tables as
select *
from reservation_tables
where false;

drop trigger if exists check_visitor_access_on_reservation_tables_trigger on reservation_tables;
drop function if exists check_visitor_access_on_reservation_tables();

CREATE OR REPLACE FUNCTION check_visitor_access_on_reservation_tables()
    RETURNS TRIGGER AS
$$
begin
    if current_user != 'anon' then
        if tg_op ='DELETE' then
            return old;
        else
            return new;
        end if;
    end if;

    if tg_op = 'INSERT' then
        raise exception 'Access denied: Visitor cannot add table to reservation';
    elsif tg_op = 'UPDATE' then
        raise exception 'Access denied: Visitor cannot update table reservation';
    elsif tg_op = 'DELETE' then
        raise exception 'Access denied: Visitor cannot remove table from reservation';
    end if;

    if tg_op ='DELETE' then
        return old;
    else
        return new;
    end if;
end
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_visitor_access_on_reservation_tables_trigger
    BEFORE UPDATE OR DELETE OR INSERT
    ON reservation_tables
    FOR EACH ROW
EXECUTE FUNCTION check_visitor_access_on_reservation_tables();
--#endregion

--#region Access-table-restaurant_managers

-- Table Restaurant_managers:

-- READ: non
-- CREATE: non
-- UPDATE: N/A
-- DELETE: non

create or replace view v_acces_visitor_on_restaurant_managers as
select *
from restaurant_managers
where false;

drop trigger if exists check_visitor_access_on_restaurant_managers_trigger on restaurant_managers;
drop function if exists check_visitor_access_on_restaurant_managers();

CREATE OR REPLACE FUNCTION check_visitor_access_on_restaurant_managers()
    RETURNS TRIGGER AS
$$
begin
    if current_user != 'anon' then
        if tg_op ='DELETE' then
            return old;
        else
            return new;
        end if;
    end if;

    if tg_op = 'INSERT' then
        raise exception 'Access denied: Visitor cannot create restaurant manager';
    elsif tg_op = 'UPDATE' then
        raise exception 'Access denied: Visitor cannot update restaurant manager';
    elsif tg_op = 'DELETE' then
        raise exception 'Access denied: Visitor cannot delete restaurant manager';
    end if;

    if tg_op ='DELETE' then
        return old;
    else
        return new;
    end if;
end
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_visitor_access_on_restaurant_managers_trigger
    BEFORE UPDATE OR DELETE OR INSERT
    ON restaurant_managers
    FOR EACH ROW
EXECUTE FUNCTION check_visitor_access_on_restaurant_managers();
--#endregion

--#region Access-table-system_time

-- Table Date simulée:

-- READ: oui
-- CREATE: non
-- UPDATE: oui
-- DELETE: non

create or replace view v_acces_visitor_on_system_time as
select *
from system_time
where current_user = 'anon';

drop trigger if exists check_visitor_access_on_system_time_trigger on system_time;
drop function if exists check_visitor_access_on_system_time();

CREATE OR REPLACE FUNCTION check_visitor_access_on_system_time()
    RETURNS TRIGGER AS
$$
begin
    if current_user != 'anon' then
        if tg_op ='DELETE' then
            return old;
        else
            return new;
        end if;
    end if;

    if tg_op = 'INSERT' then
        raise exception 'Access denied: Visitor cannot create system time.';
    elsif tg_op = 'DELETE' then
        raise exception 'Access denied: Visitor cannot delete system time.';
    end if;

    if tg_op ='DELETE' then
        return old;
    else
        return new;
    end if;
end
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_visitor_access_on_system_time_trigger
    BEFORE UPDATE OR DELETE OR INSERT
    ON system_time
    FOR EACH ROW
EXECUTE FUNCTION check_visitor_access_on_system_time();
--#endregion
