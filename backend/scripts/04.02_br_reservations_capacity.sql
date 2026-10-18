set search_path to public;

/*(BR-02) Le nombre de convives d'une réservation confirmée ou terminée ne peut pas dépasser
la capacité totale des tables associées à la réservation. Ceci implique qu'une réservation confirmée
ou terminée doit avoir au moins une table réservée appartenant au restaurant de la réservation.*/

create or replace function check_reservation_capacity()
    returns trigger as
$$
begin
    if exists(select r.id, r.number_of_guests, coalesce(sum(t.capacity), 0)
              from reservations r
                  left join reservation_tables rt on rt.reservation = r.id
                  left join tables t on t.id = rt."table"
              where r.status in ('confirmed'::status_type, 'completed'::status_type)
              group by r.id, r.number_of_guests
              having r.number_of_guests > coalesce(sum(t.capacity), 0)) then
            raise exception 'BR_02 : Le nombre de convives dépasse la capacité totale.';
    end if;
    return null;
end;
$$ language plpgsql security definer;

CREATE CONSTRAINT TRIGGER trigger_validate_reservation_capacity
    AFTER INSERT OR UPDATE OF number_of_guests, status
    ON reservations
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW
EXECUTE FUNCTION check_reservation_capacity();

DROP TRIGGER IF EXISTS trigger_validate_reservation_tables_capacity ON reservation_tables;

CREATE CONSTRAINT TRIGGER trigger_validate_reservation_tables_capacity
    AFTER DELETE
    ON reservation_tables
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW
EXECUTE FUNCTION check_reservation_capacity();

CREATE OR REPLACE TRIGGER trigger_validate_tables_capacity
    AFTER UPDATE OF capacity OR DELETE
    ON tables
    FOR EACH ROW
EXECUTE FUNCTION check_reservation_capacity();
