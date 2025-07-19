with
    city as (
        select distinct city_id, city_name, lat as latitude, lon as longitude, country
        from {{ ref("weather") }}
    )
select {{ dbt_utils.generate_surrogate_key(["city_id"]) }} as dim_city_key, *
from city
