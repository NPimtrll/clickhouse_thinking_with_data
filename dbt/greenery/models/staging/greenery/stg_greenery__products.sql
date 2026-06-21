with 

source as (

    select * from {{ source('greenery', 'products') }}

)

select
    product_id,
    name,
    price,
    inventory
from source
