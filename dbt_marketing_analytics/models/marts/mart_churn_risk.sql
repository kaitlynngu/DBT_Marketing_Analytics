-- mart_churn_risk.sql
-- Churn risk scoring based on recency of last transaction
-- and number of months since acquisition
-- Simple rule-based scorer — good foundation for ML extension

with customers as (
    select * from {{ ref('stg_customers') }}
),

transactions as (
    select * from {{ ref('stg_transactions') }}
),

-- get last activity per customer
last_activity as (
    select
        customer_id,
        max(transaction_date)       as last_transaction_date,
        count(transaction_id)       as total_transactions,
        sum(net_amount)             as total_revenue
    from transactions
    where is_refund = false
    group by 1
),

final as (
    select
        c.customer_id,
        c.acquisition_channel,
        c.plan_tier,
        c.acquisition_month,
        l.last_transaction_date,
        l.total_transactions,
        l.total_revenue,

        -- days since last transaction (as of latest data point)
        datediff('day',
            l.last_transaction_date,
            cast('2023-04-30' as date)
        )                                           as days_since_last_txn,

        -- churn risk score (rule-based)
        case
            when l.last_transaction_date is null then 'high'
            when datediff('day',
                l.last_transaction_date,
                cast('2023-04-30' as date)
            ) > 60 then 'high'
            when datediff('day',
                l.last_transaction_date,
                cast('2023-04-30' as date)
            ) > 30 then 'medium'
            else 'low'
        end                                         as churn_risk,

        -- flag customers with no transactions at all
        case
            when l.customer_id is null then true
            else false
        end                                         as never_transacted

    from customers c
    left join last_activity l on c.customer_id = l.customer_id
)

select * from final
order by days_since_last_txn desc nulls first
