# Script Calling Relationship of s1 and s2

## Script Calling Relationship of s1_start_saleor_and_place_order_by_graphql.sh

```mermaid
graph TD
    A["s1_start_saleor_and_place_order_by_graphql.sh"] --> B["s1_start_saleor.sh"]
    
    style A fill:#f9f,stroke:#333,stroke-width:2px,color:#000
    style B fill:#bbf,stroke:#333,stroke-width:2px,color:#000
```



## Script Calling Relationship of s2_to_s4_start_and_place_order_by_storefront.sh

```mermaid
graph TD
    A["s2_to_s4_start_and_place_order_by_storefront.sh"] --> B["s2_to_s4_start.sh"]
    B --> C["s2_start_storefront.sh"]
    B --> D["s3_start_dummy_payment_app.sh"]
    B --> E["s4_start_ngrok.sh"]
    
    style A fill:#f9f,stroke:#333,stroke-width:2px,color:#000
    style B fill:#bbf,stroke:#333,stroke-width:2px,color:#000
    style C fill:#bbf,stroke:#333,stroke-width:2px,color:#000
    style D fill:#bbf,stroke:#333,stroke-width:2px,color:#000
    style E fill:#bbf,stroke:#333,stroke-width:2px,color:#000
```