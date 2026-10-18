set search_path to public;

begin;
do
$test$
    begin
        raise notice 'TEST BR-04: invalide_1';
        perform should_fail($$
            INSERT INTO reservations (client, restaurant, datetime, number_of_guests)
            VALUES (3, 1, '2026-04-27 11:00:00', 2);
        $$, 'raise_exception');
    end
$test$;
rollback;

begin;
do
$test$
    begin
        raise notice 'TEST BR-04: invalide_2';
        perform should_fail($$
            INSERT INTO reservations (client, restaurant, datetime, number_of_guests)
            VALUES (3, 1, '2026-04-27 23:00:00', 2);
        $$, 'raise_exception');
    end
$test$;
rollback;

begin;
do
$test$
    begin
        raise notice 'TEST BR-04: invalide_3';
        perform should_fail($$
            INSERT INTO reservations (client, restaurant, datetime, number_of_guests)
            VALUES (3, 1, '2026-05-03 23:00:00', 2);
        $$, 'raise_exception');
    end
$test$;
rollback;

begin;
do
$test$
    begin
        raise notice 'TEST BR-04: valide_1';
        INSERT INTO reservations (client, restaurant, datetime, number_of_guests)
        VALUES (3, 1, '2026-04-27 20:00:00', 2);

        set constraints all immediate;
    end
$test$;
rollback;

begin;
do
$test$
    begin
        raise notice 'TEST BR-04: valide_2';
        INSERT INTO reservations (client, restaurant, datetime, number_of_guests)
        VALUES (3, 1, '2026-04-27 13:00:00', 2);

        set constraints all immediate;
    end
$test$;
rollback;

begin;
do
$test$
    begin
        raise notice 'TEST BR-04: valide_3';
        INSERT INTO reservations (client, restaurant, datetime, number_of_guests)
        VALUES (3, 1, '2026-05-03 13:00:00', 2);

        set constraints all immediate;
    end
$test$;
rollback;

begin;
do
$test$
    begin
        raise notice 'TEST BR-04: invalide_4';
        perform should_fail($$
            DELETE FROM services WHERE id = 2;
        $$, 'raise_exception');
    end
$test$;
rollback;

begin;
do
$test$
    begin
        raise notice 'TEST BR-04: invalide_5';
        perform should_fail($$
            UPDATE services
            SET start_time = '01:00:00', end_time = '02:00:00'
            WHERE id = 6;
        $$, 'raise_exception');
    end
$test$;
rollback;

