-- mart_cohort_retention.sql
-- Monthly cohort retention analysis
-- Tracks what % of customers from each acquisition cohort
-- are still transacting in subsequent months

with customers as (
    select * from {{ ref('stg_customers') }}
),

transactions as (
    select * from {{ ref('stg_transactions') }}
),

-- join customers to transactions to get cohort and activity month
customer_activity as (
    select
        c.customer_id,
        c.acquisition_month                             as cohort_month,
        t.transaction_month                             as activity_month,
        datediff('month',
            c.acquisition_month,
            t.transaction_month
        )                                               as months_since_acquisition
    from customers c
    inner join transactions t on c.customer_id = t.customer_id
    where t.is_refund = false
),

-- count unique active customers per cohort per month offset
cohort_activity as (
    select
        cohort_month,
        months_since_acquisition,
        count(distinct customer_id)     as active_customers
    from customer_activity
    group by 1, 2
),

-- get cohort size (month 0 = acquisition month)
cohort_size as (
    select
        cohort_month,
        active_customers                as cohort_size
    from cohort_activity
    where months_since_acquisition = 0
),

final as (
    select
        a.cohort_month,
        a.months_since_acquisition,
        a.active_customers,
        s.cohort_size,
        round(
            100.0 * a.active_customers / s.cohort_size,
            1
        )                               as retention_rate_pct
    from cohort_activity a
    left join cohort_size s on a.cohort_month = s.cohort_month
)

select * from final
order by cohort_month, months_since_acquisition
