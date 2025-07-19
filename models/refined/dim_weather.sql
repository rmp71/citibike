select *,
    {{ dbt_utils.generate_surrogate_key(['weather_id', 'observation_time']) }} as dim_weather_key 
from {{ ref('weather') }}