with
    trips as (
        select distinct
            fact_bike_trip_key,
            dim_weather_key,
            start_time,
            promotion_details,
            trip_duration_seconds,
            distance_km
        from {{ ref("fact_bike_trips") }}
        where start_time::date >= '2017-01-01'
    ),
    weather as (select dim_weather_key, weather_main from {{ ref("dim_weather") }})
select
    t.fact_bike_trip_key,
    t.start_time,
    t.promotion_details,
    t.trip_duration_seconds,
    t.distance_km,
    coalesce(w.weather_main, 'Unknown') as weather_type
from trips t
left join weather w on (t.dim_weather_key = w.dim_weather_key)
