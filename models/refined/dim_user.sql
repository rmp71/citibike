with
    users as (
        select distinct user_type, birth_year, gender from {{ ref("citibike_trips") }}
    )
select
    {{ dbt_utils.generate_surrogate_key(["user_type", "birth_year", "gender"]) }}
    as dim_user_key,
    user_type,
    birth_year,
    case
        when gender = 0
        then 'Unknown'
        when gender = 1
        then 'Male'
        when gender = 2
        then 'Female'
    end as gender
from users
