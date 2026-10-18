set search_path to public;
-- INSERT --
 -- cas negatif --
begin;
INSERT INTO reservations (id, client, restaurant, datetime, number_of_guests, status)
VALUES (100, 3, 1, '2027-05-10 12:30:00', 2, 'pending');
do
$test$
begin
        raise notice 'TEST BR-13: un client ne peut pas réserver deux fois pour le service à midi';
        perform should_fail($$
            INSERT INTO reservations (id, client, restaurant, datetime, number_of_guests, status)
            VALUES (101, 3, 1, '2027-05-10 13:30:00', 4, 'pending');
        $$, 'raise_exception');
end
$test$;
rollback;
-- cas positif --
begin;
do
$test$
begin
    raise notice 'TEST BR-13: réservations midi et soir acceptées pour le même client';
    INSERT INTO reservations (id, client, restaurant, datetime, number_of_guests, status)
    VALUES (200, 3, 1, '2027-05-03 12:30:00', 2, 'pending');

    INSERT INTO reservations (id, client, restaurant, datetime, number_of_guests, status)
    VALUES (201, 3, 1, '2027-05-03 20:00:00', 2, 'pending');
    set constraints all immediate;
end
$test$;
rollback;

-- UPDATE --

-- cas negatif
begin;
INSERT INTO reservations (id, client, restaurant, datetime, number_of_guests, status)
VALUES (105, 3, 1, '2027-11-15 12:30:00', 2, 'pending');
do
$test$
    begin
        RAISE NOTICE 'TEST BR-13: déjà une réservation a ce créneau.';
        PERFORM should_fail($$
            UPDATE reservations
            SET datetime = '2027-11-15 13:00:00'
            WHERE id = 1
            $$, 'raise_exception');
    end
$test$;
rollback;

-- cas positif

begin;
do
$test$
    begin
        RAISE NOTICE 'TEST BR-13: créneau libre donc reussi.';
        UPDATE reservations
        SET datetime = '2027-11-15 20:00:00'
        WHERE id = 1;
        set constraints all immediate;
    end
$test$;
rollback;