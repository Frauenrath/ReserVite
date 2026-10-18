set search_path to public, auth;

create or replace function get_system_time()
    returns json as
$$
begin

    return(select row_to_json(r)
            from (select simulated_time
                  from system_time
                 ) r
            );

end;
$$language plpgsql security definer;

grant execute on function get_system_time() to anon;

create or replace function set_system_time(new_time timestamp)
    returns void as
$$
begin

    update system_time
    set simulated_time = new_time;

end;
$$language plpgsql security definer;

grant execute on function set_system_time to anon;