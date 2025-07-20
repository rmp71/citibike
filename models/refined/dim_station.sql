with
    stations as (
        select distinct
            start_station_id as station_id,
            start_station_name as station_name,
            start_station_latitude as station_latitude,
            start_station_longitude as station_longitude
        from {{ ref("citibike_trips") }}
        union
        select distinct
            end_station_id as station_id,
            end_station_name as station_name,
            end_station_latitude as station_latitude,
            end_station_longitude as station_longitude
        from {{ ref("citibike_trips") }}
    ),
    city as (select distinct lat, lon, city_id from {{ ref("weather") }}),
    city_join as (
        select distinct s.*, c.city_id
        from stations s
        left join city c on (s.station_latitude = c.lat and s.station_longitude = c.lon)
    )
select
    {{
        dbt_utils.generate_surrogate_key(
            [
                "station_id",
                "station_name",
                "station_latitude",
                "station_longitude",
                "city_id",
            ]
        )
    }} as dim_station_key, *
from city_join
