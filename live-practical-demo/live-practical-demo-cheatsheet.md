# QECon 2025 Shanghai Live Practical Demo Cheatsheet

## p15

```bash
# Start Docker Desktop
./s4_to_s1_stop.sh
./clean_up_data.sh
# Running Saleor Locally
https://docs.saleor.io/quickstart/running-locally

# Build Docker images by cloning the repository and running the following commands:
# git clone https://github.com/saleor/saleor-platform.git
cd saleor-platform
# docker compose pull

# update the database schema to the latest version
docker compose run --rm api python3 manage.py migrate

# populate the database with sample data
docker compose run --rm api python3 manage.py populatedb

# add admin user name and password
docker compose run --rm api python3 manage.py createsuperuser

# admin@example.com / admin

# Run all Saleor containers (from within the saleor-platform directory)
docker compose up

# The dashboard will now be available at localhost:9000.

```

### API Walkthrough

https://docs.saleor.io/quickstart/api

1. 打开GraphQL Playground: http://localhost:8000/graphql/

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

## p18

```bash
# 用graphql下单并初始化admin@example.com的shipping地址数据
./s4_to_s1_stop.sh
./clean_up_data.sh
./s1_start_saleor_and_place_order_by_graphql.sh
# 能在webhook.site看到POST信息
```

## p21

```bash
# Running Storefront

https://github.com/saleor/storefront

## Install Storefront manually

# git clone https://github.com/saleor/storefront.git saleor-storefront-installed-manually

cd saleor-storefront-installed-manually

# 安装依赖 (这一步很关键！)
pnpm install

# Copy environment variables
# cp .env.example .env

## Add local backend API URL in .env

# Add local backend API URL
# Make sure to add slash at the end:
# NEXT_PUBLIC_SALEOR_API_URL=http://localhost:8000/graphql/

## Run Storefront

pnpm run dev

## Place an order

# 1. Open http://localhost:3000/
# 2. Browse products and add them to the cart
# 3. Proceed to checkout
# 4. Complete the checkout process
# 5. Place the order
# 6. Check the order in webhook.site

```

## p22

```shell
# 用storefront下单
# 在终端中停止storefront的运行
./s2_to_s4_start_and_place_order_by_storefront.sh
# 在Storefront中购物下单
# 能在webhook.site看到POST信息

```

## p40

```shell
# Start Docker Desktop
cd start_saleor
./s4_to_s1_stop.sh
./clean_up_data.sh
./s1_start_saleor_and_place_order_by_graphql.sh
./s2_to_s4_start_and_place_order_by_storefront.sh
cd ../saleor-smoke-testing
npm install && npm run test:install
npm run test:fast
npm run test:headed
npm run test:report
```