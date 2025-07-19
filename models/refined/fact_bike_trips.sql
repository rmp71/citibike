with
    trips as (
        select
            {{
                dbt_utils.generate_surrogate_key(
                    ["user_type", "birth_year", "gender"]
                )
            }} as dim_user_key,
            {{
                dbt_utils.generate_surrogate_key(
                    [
                        "start_station_id",
                        "start_station_name",
                        "start_station_latitude",
                        "start_station_longitude",
                    ]
                )
            }} as dim_start_station_key,
            {{
                dbt_utils.generate_surrogate_key(
                    [
                        "end_station_id",
                        "end_station_name",
                        "end_station_latitude",
                        "end_station_longitude",
                    ]
                )
            }} as dim_end_station_key,
            bike_id,
            promotion_details,
            start_time,
            stop_time,
            trip_duration,
            datediff(minute, start_time, stop_time) as duration_minutes,
            {{
                haversine(
                    "start_station_latitude",
                    "start_station_longitude",
                    "end_station_latitude",
                    "end_station_longitude",
                )
            }} as distance_km
        from {{ ref("citibike_trips") }}
    ),

    weather_joined as (
        select
            t.*,
            {{
                dbt_utils.generate_surrogate_key(
                    ["weather_id", "observation_time", "city_id"]
                )
            }} as dim_weather_key
        from trips t
        left join
            {{ ref("weather") }} w
            on date_trunc('hour', t.start_time) = w.observation_time
    )

select *
from weather_joined
