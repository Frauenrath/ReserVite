set search_path to public;

/* TEST BR-10: table restaurant_managers*/

begin;
do
$test$
    begin
        raise notice 'TEST BR-10: supp invalide';
        perform should_fail($$
            DELETE FROM restaurant_managers WHERE restaurant = 5;
        $$, 'raise_exception');
    end
$test$;
rollback;

begin;
do
$test$
    begin
        raise notice 'TEST BR-10: supp valide';
        DELETE FROM restaurant_managers WHERE restaurant = 1 AND manager = 2;

        set constraints all immediate;
    end
$test$;
rollback;

/* TEST BR-10: table reservations*/

begin;
do
$test$
    DECLARE new_restaurant_id int;
    begin
        raise notice 'TEST BR-10: ajout valide';
        INSERT INTO restaurants(name, address, city, phone, slot_duration)
        VALUES('testtest', 'testtest', 'Bruxelles','+32 2 123 45 61',60)
        RETURNING id INTO new_restaurant_id;

        INSERT INTO restaurant_managers(restaurant, manager)
        VALUES (new_restaurant_id, 2);

        set constraints all immediate;
    end
$test$;
rollback;

begin;
do
$test$
    begin
        raise notice 'TEST BR-10: ajout invalide';
        perform should_fail('INSERT INTO restaurants(name, address, city, phone, slot_duration)
        VALUES(''testtest'', ''testtest'', ''Bruxelles'',''+32 2 123 45 61'',60);');
    end
$test$;
rollback;

