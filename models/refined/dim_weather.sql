with
    weather as (
        select distinct
            weather_id,
            city_id,
            weather_main,
            weather_description,
            weather_icon,
            cloud_cover,
            humidity,
            pressure,
            temperature as average_temperature,
            temp_min as minimum_temperature,
            temp_max as maximum_temperature,
            observation_time,
            wind_speed,
            wind_deg as wind_degree
        from {{ ref("weather") }}
    )
select
    {{
        dbt_utils.generate_surrogate_key(
            ["weather_id", "observation_time", "city_id"]
        )
    }} as dim_weather_key,
    city_id,
    weather_id,
    weather_main,
    weather_description,
    weather_icon,
    cloud_cover,
    humidity,
    pressure,
    average_temperature,
    minimum_temperature,
    maximum_temperature,
    observation_time,
    wind_speed,
    wind_degree
from weather
