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
    )
select
    {{
        dbt_utils.generate_surrogate_key(
            ["station_id", "station_name","station_latitude", "station_longitude"]
        )
    }} as dim_station_key,
    *
from stations
