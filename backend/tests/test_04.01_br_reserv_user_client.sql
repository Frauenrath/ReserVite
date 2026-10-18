set search_path to public;

begin;
do
$test$
    begin
        raise notice 'TEST BR-01: invalide';
        perform should_fail($$
            INSERT INTO reservations (client, restaurant, datetime, number_of_guests, status)
            VALUES (8, 1, '2024-11-15 13:00:00', 2, 'pending');
        $$, 'raise_exception');
    end
$test$;
rollback;

begin;
do
$test$
    begin
        raise notice 'TEST BR-01: valide';
        insert into reservations (client, restaurant, datetime, number_of_guests, status)
        VALUES (3, 1, '2028-11-15 13:00:00', 2, 'pending');

        set constraints all immediate;
    end
$test$;
rollback;