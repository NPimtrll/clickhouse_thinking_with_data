{{
    config(
        materialized='table',
    )
}}
with fct_order_items as (

    select * from {{ ref('fct_order_items') }}

),

product_revenue as (

    select
        product_id,
        sum(item_revenue) as gross_revenue
    from fct_order_items
    group by product_id

)

select
    product_id,
    gross_revenue,
    row_number() over (order by gross_revenue desc) as revenue_rank
from product_revenue
order by gross_revenue desc
limit 10
