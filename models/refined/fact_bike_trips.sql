with trips as (
    select
        trip_id,
        customer_id,
        start_time,
        end_time,
        start_station_id,
        end_station_id,
        datediff(minute, start_time, end_time) as duration_minutes,
        {{ haversine('start_station_latitude', 'start_station_longitude', 'end_station_latitude', 'end_station_longitude') }} as distance_km
    from {{ ref('citibike_trips') }}
),

weather_joined as (
    select
        t.*,
        {{ dbt_utils.generate_surrogate_key(['weather_id', 'observation_time']) }} as dim_weather_key
    from trips t
    left join {{ ref('weather') }} w
      on date_trunc('hour', t.start_time) = w.observation_time
)

select * from weather_joined