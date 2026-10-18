set search_path to public;

/*09. Une nouvelle réservation doit avoir le status pending.
  Une réservation existante ne peut pas revenir "en arrière" dans son cycle de vie.
  Les tansitions autorisées sont :
  pending -> confirmed
  pending -> cancelled
  confrimed -> completed
  confirmed -> cancelled
  La transition confirmed -> pending est autorisée dans certains cas (voir régles temporelles).
  Aucune transition depuis completed ou cancelled n'est pas autorisée.*/

CREATE OR REPLACE FUNCTION  prevent_reservation_modify()
RETURNS trigger as $$
    declare currentTime TIMESTAMP;
BEGIN
    SELECT simulated_time INTO currentTime
    FROM system_time LIMIT 1;

    IF tg_op = 'INSERT' THEN
        IF new.status NOT IN ('pending') THEN
        RAISE EXCEPTION 'BR-09: Impossible de créer un nouveau status autre que pending';
        END IF;
        RETURN NEW;
    END IF;

    IF old.status = new.status THEN
        RETURN NEW;
    end if;

    IF old.status = 'pending' THEN
        IF NEW.status NOT IN ('confirmed', 'cancelled') THEN
            RAISE EXCEPTION 'BR-09: Depuis pending seul confirmed ou cancelled est possible';
        END IF;
    ELSIF old.status = 'confirmed' THEN
        IF new.status = 'pending' THEN
            IF new.datetime <= currentTime THEN
                RAISE EXCEPTION 'BR-09: Le retour à pending n''est pas possible que pour une date future';
            END IF;
        ELSIF new.status NOT IN ('completed', 'cancelled') THEN
                RAISE EXCEPTION 'BR-09: Transition invalide depuis confirmed';
        end if;

    ELSIF old.status IN ('completed', 'cancelled') THEN
        RAISE EXCEPTION 'BR-09: Une réservation terminée ou annulée ne peut pas changer';
    ELSE
        RAISE EXCEPTION 'BR-09: Transition de % vers % interdite', OLD.status, NEW.status;
    END IF;

RETURN NEW;
END;
$$LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_prevent_reservation_modify ON reservations;

CREATE TRIGGER trg_prevent_reservation_modify
    BEFORE INSERT OR UPDATE ON reservations
    FOR EACH ROW
EXECUTE FUNCTION prevent_reservation_modify();