set search_path to public;

begin;
do
$test$
    begin
        raise notice 'TEST BR-03: invalide';
        perform should_fail($$
            INSERT INTO reservation_tables (reservation, "table")
            VALUES (1, 4);
        $$, 'raise_exception');
    end
$test$;
rollback;

begin;
do
$test$
    begin
        raise notice 'TEST BR-03: valide';
        INSERT INTO reservation_tables (reservation, "table")
        VALUES (1, 2);

        set constraints all immediate;
    end
$test$;
rollback;