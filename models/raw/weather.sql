with
    base as (
        select
            raw:city:name::string as city_name,
            raw:city:findname::string as findname,
            raw:city:id::number as city_id,
            raw:city:coord:lat::float as lat,
            raw:city:coord:lon::float as lon,
            raw:city:country::string as country,
            raw:city:zoom::int as zoom,
            raw:clouds:all::int as cloud_cover,
            raw:main:humidity::int as humidity,
            raw:main:pressure::int as pressure,
            raw:main:temp::float as temperature,
            raw:main:temp_min::float as temp_min,
            raw:main:temp_max::float as temp_max,
            to_timestamp(raw:time::int) as observation_time,
            raw:wind:speed::float as wind_speed,
            raw:wind:deg::int as wind_deg,
            raw:weather as weather_array,
            raw:city:langs as langs_array
        from {{ source("landing", "weather") }}
        -- where raw:time::int > unix_timestamp('2024-01-01')
    ),
    flattened_weather as (
        select distinct
            base.*,
            weather.value:id::int as weather_id,
            weather.value:main::string as weather_main,
            weather.value:description::string as weather_description,
            weather.value:icon::string as weather_icon
        from base, lateral flatten(input => base.weather_array) as weather
    )

    -- flattened_langs as (
    --     select
    --         base.city_id,
    --         lang.value::string as lang_value,
    --         object_keys(lang.value)[0] as lang_key,
    --         lang.value:abbr::string as abbr
    --     from base, lateral flatten(input => base.langs_array) as lang
    -- )

select 
    f.city_name,
    f.findname,
    f.city_id,
    f.lat,
    f.lon,
    f.country,
    f.zoom,
    f.cloud_cover,
    f.humidity,
    f.pressure,
    f.temperature,
    f.temp_min,
    f.temp_max,
    f.observation_time,
    f.wind_speed,
    f.wind_deg,
    f.weather_id,
    f.weather_main,
    f.weather_description,
    f.weather_icon
    -- l.lang_key,
    -- l.lang_value,
    -- l.abbr
from flattened_weather f
-- left join flattened_langs l on f.city_id = l.city_id
