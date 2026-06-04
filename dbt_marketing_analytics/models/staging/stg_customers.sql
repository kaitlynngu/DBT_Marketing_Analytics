-- stg_customers.sql
-- Cleans and standardizes the raw customers seed data

with source as (
    select * from {{ ref('customers') }}
),

staged as (
    select
        customer_id,
        cast(acquisition_date as date)          as acquisition_date,
        lower(acquisition_channel)              as acquisition_channel,
        lower(acquisition_campaign)             as acquisition_campaign,
        upper(country)                          as country,
        age_group,
        lower(plan_tier)                        as plan_tier,
        date_trunc('month', cast(acquisition_date as date)) as acquisition_month
    from source
    where customer_id is not null
)

select * from staged
