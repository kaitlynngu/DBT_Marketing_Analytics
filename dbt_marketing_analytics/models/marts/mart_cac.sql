-- mart_cac.sql
-- Customer Acquisition Cost by channel and campaign month
-- CAC = total spend / number of new customers acquired

with customers as (
    select * from {{ ref('stg_customers') }}
),

spend as (
    select * from {{ ref('stg_campaign_spend') }}
),

-- count new customers per channel per month
acquisitions as (
    select
        acquisition_channel     as channel,
        acquisition_month,
        count(customer_id)      as new_customers
    from customers
    group by 1, 2
),

-- sum spend per channel per month
channel_spend as (
    select
        channel,
        campaign_month,
        sum(spend_usd)          as total_spend
    from spend
    group by 1, 2
),

-- join and calculate CAC
final as (
    select
        a.channel,
        a.acquisition_month,
        a.new_customers,
        coalesce(s.total_spend, 0)                                      as total_spend,
        case
            when a.new_customers = 0 then null
            else round(coalesce(s.total_spend, 0) / a.new_customers, 2)
        end                                                             as cac_usd
    from acquisitions a
    left join channel_spend s
        on a.channel = s.channel
        and a.acquisition_month = s.campaign_month
)

select * from final
order by acquisition_month, channel
