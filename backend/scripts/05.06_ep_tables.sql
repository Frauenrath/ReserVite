set search_path to public, auth;

create or replace function get_tables_for_reservations(reservationsId int)
returns setof json as
$$
declare v_restaurant_id int;
declare v_datetime timestamp;
begin
    perform auth.check_logged();
    if auth.role() != 'manager' then
        raise exception 'access denied: you need to have the manager role to execute this action';
    end if;

    select r.restaurant , r.datetime into v_restaurant_id , v_datetime
    from reservations r
    where r.id = reservationsId;

    return query
        select json_build_object(
                'id', t.id,
                'restaurant', t.restaurant,
                'table_number', t.table_number,
                'capacity', t.capacity,
                'is_currently_assigned', EXISTS(select 1
                                                FROM reservation_tables
                                                WHERE reservation = reservationsId
                                                  AND t.id = "table"),
                'is_available', NOT EXISTS(select 1
                                           from reservation_tables rt join reservations r on rt.reservation = r.id
                                           where r.id != reservationsId
                                             AND rt."table" = t.id
                                             and r.datetime = v_datetime
                                             and r.status in ('pending' , 'confirmed'))
               )
        from tables t
        where t.restaurant = v_restaurant_id;
end;
$$ language  plpgsql security definer;

grant execute on function get_tables_for_reservations to authenticated;