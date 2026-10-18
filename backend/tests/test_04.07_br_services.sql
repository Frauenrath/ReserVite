set search_path to public;

-- cas negatif
begin;
do
$test$
    begin
        RAISE NOTICE 'TEST BR-07:le service ne peut pas ce chevaucher dans le meme restaurant';
        PERFORM should_fail($$
            INSERT INTO services (id, restaurant, day_of_week, start_time, end_time)
            VALUES (89, 1, 1, '13:00:00', '16:00:00')
            $$, 'raise_exception');
    end
$test$;
rollback;

-- cas positif

begin;
do
$test$
    begin
        RAISE NOTICE 'TEST BR-07:le service peut etre admis car aucun service est a cette heure la ';
        INSERT INTO services (id, restaurant, day_of_week, start_time, end_time)
        VALUES (89,1,1,'15:00:00', '18:00:00');
        set constraints all immediate;
    end
$test$;
rollback;
