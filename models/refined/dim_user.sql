with
    users as (
        select distinct user_type, birth_year, gender from {{ ref("citibike_trips") }}
    )
select
    {{ dbt_utils.generate_surrogate_key(["user_type", "birth_year", "gender"]) }}
    as dim_user_key,
    user_type,
    birth_year,
    year(current_date()) - birth_year as age,
    case
        when age >= 0 and age <= 20
        then '0-20 Years'
        when age > 20 and age <= 40
        then '21-40 Years'
        when age > 40 and age <= 60
        then '41-60 Years'
        when age > 60 and age <= 80
        then '61-80 Years'
        when age > 80
        then '81+ Years'
        else 'Unknown'
    end as age_bucket,
    case
        when gender = 0
        then 'Unknown'
        when gender = 1
        then 'Male'
        when gender = 2
        then 'Female'
    end as gender
from users
