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
                        "ss.city_id",
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
                        "se.city_id",
                    ]
                )
            }} as dim_end_station_key,
            {{
                dbt_utils.generate_surrogate_key(
                    [
                        "user_type",
                        "birth_year",
                        "gender",
                        "start_station_id",
                        "start_station_name",
                        "start_station_latitude",
                        "start_station_longitude",
                        "end_station_id",
                        "end_station_name",
                        "end_station_latitude",
                        "end_station_longitude",
                        "bike_id",
                        "promotion_details",
                        "start_time",
                        "stop_time",
                        "trip_duration"
                    ]
                )
            }} as fact_bike_trip_key,
            c.bike_id,
            c.promotion_details,
            c.start_time,
            c.stop_time,
            ss.city_id as start_city_id,
            se.city_id as end_city_id,
            c.trip_duration as trip_duration_seconds,
            {{
                haversine(
                    "start_station_latitude",
                    "start_station_longitude",
                    "end_station_latitude",
                    "end_station_longitude",
                )
            }} as distance_km
        from {{ ref("citibike_trips") }} c
        left join
            {{ ref("dim_station") }} ss
            on (
                c.start_station_id = ss.station_id
                and c.start_station_name = ss.station_name
                and c.start_station_latitude = ss.station_latitude
                and c.start_station_longitude = ss.station_longitude
            )
        left join
            {{ ref("dim_station") }} se
            on (
                c.end_station_id = se.station_id
                and c.end_station_name = se.station_name
                and c.end_station_latitude = se.station_latitude
                and c.end_station_longitude = se.station_longitude
            )
    ),

    weather_joined as (
        select w.dim_weather_key, t.*
        from trips t
        left join
            {{ ref("dim_weather") }} w
            on date_trunc('hour', t.start_time) = date_trunc('hour',w.observation_time)
                and date_trunc('day',t.start_time)=date_trunc('day',w.observation_time)
                and t.start_city_id=w.city_id
        qualify
            row_number() over (
                partition by fact_bike_trip_key
                -- user_type, birth_year, gender, 
                -- start_station_id,
                -- "start_station_name","start_station_latitude","start_station_longitude",
                -- 'end_station_id',
                -- "end_station_name","end_station_latitude","end_station_longitude",
                -- 'bike_id', 'promotion_details', 'start_time'
                order by w.observation_time
            )
            = 1
    )

select *
from weather_joined
