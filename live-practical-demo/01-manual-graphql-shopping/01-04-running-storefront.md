# Running Storefront

[https://github.com/saleor/storefront](https://github.com/saleor/storefront)

## Install Storefront manually

```bash
# Install project: Clone repo and install dependencies
git clone https://github.com/saleor/storefront.git saleor-storefront-installed-manually

cd saleor-storefront-installed-manually

# 3. 安装依赖 (这一步很关键！)
pnpm install

# Copy variables: Copy environment variables from .env.example to .env:
cp .env.example .env

```

## Add local backend API URL in .env

```shell
# Add local backend API URL
# Make sure to add slash at the end:
NEXT_PUBLIC_SALEOR_API_URL=http://localhost:8000/graphql/
```

## Run Storefront

```shell
pnpm run dev
```

## Place an order

1. Open [http://localhost:3000/](http://localhost:3000/)
2. Browse products and add them to the cart
3. Proceed to checkout
4. Complete the checkout process
5. Place the order
6. Check the order in the Saleor dashboard
