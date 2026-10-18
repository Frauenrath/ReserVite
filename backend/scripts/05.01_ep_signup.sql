set search_path to public, auth;

/**************************************************************
 Fonction qui permet de vérifier si un pseudo est disponible
 **************************************************************/

create or replace function check_is_fullname_available(fullname text)
    returns boolean as
$$
begin
    return not exists(select 1 from users where lower(users.full_name) = lower(check_is_fullname_available.fullname));
end
$$ language plpgsql security definer;

grant execute on function check_is_fullname_available to anon;

/**************************************************************
 Fonction qui permet de vérifier si un email est disponible
 **************************************************************/

create or replace function check_is_email_available(email text)
    returns boolean as
$$
begin
    return not exists(select 1 from users where lower(users.email) = lower(check_is_email_available.email));
end
$$ language plpgsql security definer;

grant execute on function check_is_email_available to anon;

/**************************************************************
 Fonction signup
 **************************************************************/

create or replace function signup(fullname text, email text, password text, phone text)
    returns void as
$$
begin
    insert into users (email, password, full_name, role, phone)
    values (signup.email, signup.password, signup.fullname, 'client', signup.phone);
end
$$ language plpgsql security definer;

grant execute on function signup to anon;