-- stg_campaign_spend.sql
-- Cleans and standardizes campaign spend data

with source as (
    select * from {{ ref('campaign_spend') }}
),

staged as (
    select
        campaign_id,
        lower(campaign_name)            as campaign_name,
        lower(channel)                  as channel,
        cast(start_date as date)        as start_date,
        cast(end_date as date)          as end_date,
        cast(spend_usd as decimal(10,2)) as spend_usd,
        date_trunc('month', cast(start_date as date)) as campaign_month
    from source
    where campaign_id is not null
)

select * from staged
