set search_path to public;

--#region tests_check_Restaurants

/******************************************
  test des checks de la table Restaurants
******************************************/

/* test: Le nom doit avoir au minimum une longueur de 5 caractères. */

begin;
do
$test$
    begin
        raise notice 'TEST_check: Le nom doit avoir au minimum une longueur de 5 caractères. (cas valide)';
        update restaurants set name = 'testname' where id = 1;
    end
$test$;
rollback;

/*--------------------------------------------------------------------------------------------------------------------*/

begin;
do
$test$
    begin
        raise notice 'TEST_check: Le nom doit avoir au minimum une longueur de 5 caractères. (cas invalide)';
        perform should_fail($$
            update restaurants set name = 'a' where id = 1;
        $$, 'check_violation');
    end
$test$;
rollback;

/*--------------------------------------------------------------------------------------------------------------------*/

begin;
do
$test$
    begin
        raise notice 'TEST_check: Le nom doit avoir au minimum une longueur de 5 caractères. (cas invalide)';
        perform should_fail($$
            update restaurants set name = '      ' where id = 1;
        $$, 'check_violation');
    end
$test$;
rollback;

/**********************************************************************************************************************/
/* test: L'adresse doit avoir au minimum une longueur de 5 caractères. */

begin;
do
$test$
    begin
        raise notice 'TEST_check: Le nom doit avoir au minimum une longueur de 5 caractères. (cas valide)';
        update restaurants set address = 'testname' where id = 1;
    end
$test$;
rollback;

/*--------------------------------------------------------------------------------------------------------------------*/

begin;
do
$test$
    begin
        raise notice 'TEST_check: Le nom doit avoir au minimum une longueur de 5 caractères. (cas invalide)';
        perform should_fail($$
            update restaurants set address = 'a' where id = 1;
        $$, 'check_violation');
    end
$test$;
rollback;

/**********************************************************************************************************************/
/* test: La ville doit avoir au minimum une longueur de 3 caractères. */

begin;
do
$test$
    begin
        raise notice 'TEST_check: La ville doit avoir au minimum une longueur de 3 caractères. (cas valide)';
        update restaurants set city = 'testname' where id = 1;
    end
$test$;
rollback;

/*--------------------------------------------------------------------------------------------------------------------*/

begin;
do
$test$
    begin
        raise notice 'TEST_check: La ville doit avoir au minimum une longueur de 3 caractères. (cas invalide)';
        perform should_fail($$
            update restaurants set city = 'a' where id = 1;
        $$, 'check_violation');
    end
$test$;
rollback;

/**********************************************************************************************************************/
/* test: Le numéro de téléphone doit avoir un format de numéro belge valide, et peut être encodé avec ou
   sans espaces de séparation entre les groupes de chiffres. (à terminer) */

begin;
do
$test$
    begin
        raise notice 'TEST_check: La ville doit avoir au minimum une longueur de 3 caractères. (cas valide)';
        update restaurants set city = 'testname' where id = 1;
    end
$test$;
rollback;

/*--------------------------------------------------------------------------------------------------------------------*/

begin;
do
$test$
    begin
        raise notice 'TEST_check: La ville doit avoir au minimum une longueur de 3 caractères. (cas invalide)';
        perform should_fail($$
            update restaurants set city = 'a' where id = 1;
        $$, 'check_violation');
    end
$test$;
rollback;
--#endregion

--#region tests_check_tables

/******************************************
test des checks de la table Tables
******************************************/

/* test: On ne peut pas modifier le restaurant d'une table */

begin;
do
$test$
    begin
        raise notice 'TEST: On ne peut pas modifier le restaurant d''une table. (cas invalide)';
        perform should_fail($$
            update tables set restaurant = 1000 where id = 1;
        $$, 'raise_exception');
    end
$test$;
rollback;
/**********************************************************************************************************************/
/* La capacité doit être strictement positive. */

begin;
do
$test$
    begin
        raise notice 'TEST: La capacité de la table ne peut pas etre négative. (cas invalide)';
        perform should_fail($$
            INSERT INTO tables (restaurant, table_number, capacity) VALUES (1, 5, 0)
        $$, 'check_violation');
    end
$test$;
rollback;
/**********************************************************************************************************************/
/* Le numéro de table doit être strictement positif. */

begin;
do
$test$
    begin
        raise notice 'TEST: Le numéro de table doit être strictement positif. (cas invalide)';
        perform should_fail($$
            INSERT INTO tables (restaurant, table_number, capacity) VALUES (1, -1, 4);
        $$, 'check_violation');
    end
$test$;
rollback;
/*--------------------------------------------------------------------------------------------------------------------*/
begin;
do
$test$
    begin
        raise notice 'TEST: Le numéro de table doit être strictement positif. (cas valide)';
        update tables set table_number = 4 where id = 1;
    end
$test$;
rollback;
--#endregion

--#region tests_check_reservations

/******************************************
test des checks de la table Reservations
******************************************/

begin;
do
$test$
    begin
        raise notice 'TEST:le status doit etre obligatoirement en pending';
        PERFORM should_fail($$
            INSERT INTO reservations (id, client, restaurant, datetime, number_of_guests, status, special_requests)
            VALUES (23, 1, 1, '2024-11-15 19:00:00.000000', 2, 'confirmed', 'visite')
            $$, 'raise_exception');
    end
$test$;
rollback;
--#endregion

--#region tests_check_users

/******************************************
  Checks de la table Utilisateurs
******************************************/

/* --- Contrainte d'unicité ---*/

-- Contrainte d'unicité sur l'email de l'user.
begin;
do
$test$
    begin
        raise notice 'TEST: email du user est unique';
        perform should_fail($$
            INSERT INTO users (email, password, full_name, role)
            VALUES ('testuser01@epfc.eu', 'Password1,', 'test01', 'client');

            INSERT INTO users (email, password, full_name, role)
            VALUES ('testuser02@epfc.eu', 'Password2,', 'test02', 'client');

            update users set email = 'testuser01@epfc.eu' where full_name = 'test02';
            $$,'unique_violation');
    end
$test$;
rollback;

-- Contrainte d'unicité sur full_name_unique;
begin;
do
$test$
    begin
        raise notice 'TEST: full_name du user est unique';
        INSERT INTO users (email, password, full_name, role)
        VALUES ('testuser01@epfc.eu', 'Password1,', 'test01', 'client');

        INSERT INTO users (email, password, full_name, role)
        VALUES ('testuser02@epfc.eu', 'Password2,', 'test02', 'client');

        perform should_fail($$
            update users set full_name = 'test01' where email = 'testuser02@epfc.eu';
            $$,'unique_violation');
    end
$test$;
rollback;
/* --- Contrainte d'unicité ---*/

/* Le nom complet doit avoir une longueur d'au moins 3 caractères. */

begin;
do
$test$
    begin
        raise notice 'TEST: Le nom complet doit avoir une longueur d''au moins 3 caractères.';
        perform should_fail($$
             INSERT INTO users (email, password, full_name, role)
             VALUES ('testuser01@epfc.eu', 'Password1,', 'te', 'client');
        $$, 'check_violation');
    end
$test$;
rollback;

/* Le mot de passe doit avoir au minimum une longueur de 8 caractères,
doit contenir au moins un chiffre, une lettre majuscule,
une lettre minuscule et un caractère spécial parmi les suivants : ,;.:!?/$%&@#.*/

begin;
do
$test$
    begin
        raise notice 'TEST: Les règles métiers pour le mot de passe ne sont pas respectées.';
        perform should_fail($$
             INSERT INTO users (email, password, full_name, role)
             VALUES ('testuser01@epfc.eu', '1,', 'te', 'client');
        $$, 'raise_exception');
    end
$test$;
rollback;
--#endregion