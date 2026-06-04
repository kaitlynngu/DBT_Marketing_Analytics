-- stg_transactions.sql
-- Cleans and standardizes the raw transactions seed data

with source as (
    select * from {{ ref('transactions') }}
),

staged as (
    select
        transaction_id,
        customer_id,
        cast(transaction_date as date)              as transaction_date,
        cast(amount as decimal(10,2))               as amount,
        lower(product_category)                     as product_category,
        cast(is_refund as boolean)                  as is_refund,
        date_trunc('month', cast(transaction_date as date)) as transaction_month,

        -- net amount excluding refunds
        case
            when cast(is_refund as boolean) = true then 0
            else cast(amount as decimal(10,2))
        end                                         as net_amount
    from source
    where transaction_id is not null
)

select * from staged
