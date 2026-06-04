-- mart_ltv.sql
-- Customer Lifetime Value — total net revenue per customer
-- with segmentation by channel, plan tier, and cohort month

with customers as (
    select * from {{ ref('stg_customers') }}
),

transactions as (
    select * from {{ ref('stg_transactions') }}
),

-- aggregate revenue per customer
customer_revenue as (
    select
        customer_id,
        sum(net_amount)             as total_revenue,
        count(transaction_id)       as total_transactions,
        min(transaction_date)       as first_purchase_date,
        max(transaction_date)       as last_purchase_date,
        datediff('day',
            min(transaction_date),
            max(transaction_date)
        )                           as customer_lifespan_days
    from transactions
    group by 1
),

final as (
    select
        c.customer_id,
        c.acquisition_channel,
        c.acquisition_campaign,
        c.plan_tier,
        c.acquisition_month,
        c.country,
        c.age_group,
        coalesce(r.total_revenue, 0)        as ltv_usd,
        coalesce(r.total_transactions, 0)   as total_transactions,
        r.first_purchase_date,
        r.last_purchase_date,
        coalesce(r.customer_lifespan_days, 0) as lifespan_days,

        -- LTV tier segmentation
        case
            when coalesce(r.total_revenue, 0) >= 150  then 'high'
            when coalesce(r.total_revenue, 0) >= 50   then 'medium'
            else 'low'
        end                                 as ltv_tier
    from customers c
    left join customer_revenue r on c.customer_id = r.customer_id
)

select * from final
order by ltv_usd desc
