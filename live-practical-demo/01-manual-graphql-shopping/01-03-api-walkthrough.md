# API Walkthrough

[https://docs.saleor.io/quickstart/api](https://docs.saleor.io/quickstart/api)

1. 打开GraphQL Playground: [http://localhost:8000/graphql/](http://localhost:8000/graphql/)
2. Fetch products
```graphql
{
  products(
    first: 10
    channel: "default-channel"
    where: { minimalPrice: { range: { gte: 10, lte: 100 } } }
  ) {
    edges {
      node {
        id
        name
        category {
          id
          name
        }
      }
    }
  }
}
```
