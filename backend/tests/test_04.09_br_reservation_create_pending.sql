set search_path to public;

--cas negatif
begin;
do
$test$
    begin
        raise notice 'TEST BR-09: Creation de reservation en status confirmed';
        PERFORM should_fail($$
            INSERT INTO reservations (id, client, restaurant, datetime, number_of_guests, status)
            VALUES (23, 1, 3, '2028-11-15 13:00:00.000000', 2, 'confirmed')
            $$, 'raise_exception');
    end
$test$;
rollback;

-- cas positif

begin;
do
$test$
    begin
        RAISE NOTICE 'TEST BR-09:Creation de reservation en pending ';
        INSERT INTO reservations (id, client, restaurant, datetime, number_of_guests, status)
        VALUES (45, 3, 1, '2028-11-15 13:00:00.000000', 2, 'pending');

        set constraints all immediate;
    end
$test$;
rollback;