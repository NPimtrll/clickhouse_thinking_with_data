{{ config(materialized='table') }}
select
    product_id,
    name as product_name,
    price,
    inventory
from {{ ref('stg_greenery__products') }}
