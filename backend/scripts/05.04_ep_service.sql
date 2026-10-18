set search_path to public, auth;

create or replace function get_services()
   returns setof json as
$$
begin
    perform auth.check_logged();

    return query
    select json_build_object(
            'id', ser.id,
            'restaurant', (
            select row_to_json(r)
            from (select id, name, address, city, phone, description, rating, price_range, slot_duration
                  from restaurants
                  where id = ser.restaurant
            ) r),
            'day_of_week', ser.day_of_week,
            'start_time', ser.start_time,
            'end_time', ser.end_time
           )
    from services ser;
end;
$$language plpgsql security definer;

grant execute on function get_services() to authenticated;

-- select auth.login_for_test('mamichel@epfc.eu');
-- select get_services();
-- select auth.logout_for_test();