with
    trips as (
        select distinct
            fact_bike_trip_key,
            dim_weather_key,
            dim_user_key,
            trip_date,
            start_time,
            promotion_details,
            trip_duration_seconds,
            distance_km
        from {{ ref("fact_bike_trips") }}
        where start_time::date >= '2016-01-01'
    ),
    weather as (select dim_weather_key, weather_main,weather_description,average_temperature,wind_speed from {{ ref("dim_weather") }}),
    users as (select dim_user_key,user_type,birth_year,gender,age_bucket from {{ref("dim_user")}})
select
    1 as trip_count,
    t.trip_date,
    t.start_time,
    t.promotion_details,
    t.trip_duration_seconds,
    t.distance_km,
    coalesce(w.weather_main, 'Unknown') as weather_type,
    coalesce(w.weather_description,'Unknown') as weather_description,
    w.average_temperature,
    w.wind_speed,
    coalesce(u.user_type,'Unknown') as user_type,
    u.gender,
    u.birth_year,
    u.age_bucket
from trips t
left join weather w on (t.dim_weather_key = w.dim_weather_key)
left join users u on (t.dim_user_key = u.dim_user_key)
