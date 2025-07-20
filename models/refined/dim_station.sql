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
    cities as (select distinct lat, lon, city_id from {{ ref("weather") }}),
    station_city_distance as (
        select
            s.station_id,
            s.station_name,
            s.station_latitude,
            s.station_longitude,
            c.city_id,
            -- Haversine formula to calculate distance in km
            {{
                haversine(
                    "station_latitude",
                    "station_longitude",
                    "lat",
                    "lon",
                )
            }} as distance_km
        from stations s
        cross join cities c
    ),
    ranked as (
        select *
        from station_city_distance
        qualify row_number() over (partition by station_id,station_name,station_latitude,station_longitude order by distance_km) = 1
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
    }} as dim_station_key,
    station_id,
    station_name,
    station_latitude,
    station_longitude,
    city_id
from ranked
