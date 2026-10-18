set search_path to public;

--cas negatif
begin;
do
$test$
begin
        raise notice 'TEST BR-14: Creation d''une réservation en 2024 (invalide)';
        PERFORM should_fail($$
            INSERT INTO reservations (id, client, restaurant, datetime, number_of_guests, status)
            VALUES (105, 3, 1, '2024-01-01 12:00:00', 2, 'pending')
            $$, 'raise_exception');
end
$test$;
rollback;

-- cas positif

begin;
do
$test$
begin
        RAISE NOTICE 'TEST BR-14: Creation d''une réservation en 2027 (valide)';
        INSERT INTO reservations (id, client, restaurant, datetime, number_of_guests, status)
        VALUES (105, 3, 1, '2027-11-15 12:00:00', 2, 'pending');

        set constraints all immediate;
end
$test$;
rollback;