select
    cast(trip_duration as integer) as trip_duration,
    cast(start_time as timestamp) as start_time,
    cast(start_time as timestamp) as stop_time,
    cast(start_station_id as integer) as start_station_id,
    start_station_name,
    cast(start_station_latitude as float) as start_station_latitude,
    cast(start_station_longitude as float) as start_station_longitude,
    try_cast(nullif(end_station_id, '') as integer) as end_station_id,
    nullif(end_station_name, '') as end_station_name,
    try_cast(nullif(end_station_latitude, '') as float) as end_station_latitude,
    try_cast(nullif(end_station_longitude, '') as float) as end_station_longitude,
    cast(bike_id as integer) as bike_id,
    nullif(promotion_details, '') as promotion_details,
    nullif(user_type, '') as user_type,
    try_cast(nullif(birth_year, '') as integer) as birth_year,
    cast(gender as integer) as gender
from {{ source("landing", "citibike_trips") }}
