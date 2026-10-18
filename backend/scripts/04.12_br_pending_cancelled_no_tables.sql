set search_path to public;

/*(BR-12) Une réservation en attente ou annulée ne peut être associée à aucune une table.*/

create or replace function check_no_assoc_tables_on_reservation_tables()
    returns trigger as
$$
begin
    -- cherche directement si la réservation ciblée viole la règle
    perform 1
    from reservations
    where id = new.reservation and status in ('pending', 'cancelled');

    if found then
        raise exception 'Une réservation pending ou cancelled ne peut être associée à aucune table.';
    end if;

    return new;
end;
$$ language plpgsql security definer;

create or replace function check_no_assoc_tables_on_reservations()
    returns trigger as
$$
begin
    -- Si le nouveau statut est suspect, on regarde s'il y a des tables liées
    if new.status in ('pending', 'cancelled') then
        perform 1
        from reservation_tables
        where reservation = new.id;

        if found then
            raise exception 'Une réservation pending ou cancelled ne peut être associée à aucune table.';
        end if;
    end if;

    return new;
end;
$$ language plpgsql security definer;

DROP TRIGGER IF EXISTS trigger_no_assoc_tables_on_reservation_tables ON reservation_tables;
DROP TRIGGER IF EXISTS trigger_no_assoc_tables_on_reservations ON reservations;

CREATE CONSTRAINT TRIGGER trigger_no_assoc_tables_on_reservation_tables
    AFTER INSERT OR UPDATE
    ON reservation_tables
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW
EXECUTE FUNCTION check_no_assoc_tables_on_reservation_tables();

CREATE CONSTRAINT TRIGGER trigger_no_assoc_tables_on_reservations
    AFTER UPDATE OF status
    ON reservations
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW
EXECUTE FUNCTION check_no_assoc_tables_on_reservations();