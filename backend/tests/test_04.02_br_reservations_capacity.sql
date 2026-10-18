set search_path to public;
/* TEST BR-02: table reservation*/

begin;
do
$test$
    begin
        raise notice 'TEST BR-02: reservations invalide';
        perform should_fail($$
            update reservations SET number_of_guests = 30 where id = 3;
        $$, 'raise_exception');
    end
$test$;
rollback;

begin;
do
$test$
    begin
        raise notice 'TEST BR-02: reservations valide';
        update reservations SET number_of_guests = 1 where id = 1;

        set constraints all immediate;
    end
$test$;
rollback;

/* TEST BR-02: table tables*/

begin;
do
$test$
    begin
        raise notice 'TEST BR-02: tables invalide';
        perform should_fail($$
            update tables SET capacity = 1 where id = 1;
        $$, 'raise_exception');
    end
$test$;
rollback;

begin;
do
$test$
    begin
        raise notice 'TEST BR-02: tables valide';
        update tables SET capacity = 3 where id = 1;

        set constraints all immediate;
    end
$test$;
rollback;

/* TEST BR-02: table reservations_tables*/

begin;
do
$test$
    begin
        raise notice 'TEST BR-02: reservations_tables invalide';
        perform should_fail($$
            DELETE FROM reservation_tables WHERE reservation = 7 AND "table" = 3;
        $$, 'raise_exception');
    end
$test$;
rollback;

begin;
do
$test$
    begin
        raise notice 'TEST BR-02: reservations_tables valide';
        UPDATE tables SET capacity = 8 where id = 3;
        DELETE FROM reservation_tables WHERE reservation = 7 AND "table" = 2;

        set constraints all immediate;
    end
$test$;
rollback;