# Saleor E-commerce Demo

This project provides a set of scripts to demonstrate Saleor e-commerce functionality, including order placement through both GraphQL API and Storefront UI.

## Prerequisites

- macOS (tested on Sequoia 15.6)
- Docker and Docker Compose
- Python 3
- curl
- Chrome browser

## Project Structure

```
start_saleor/
├── s1_start_saleor_and_place_order_by_graphql.sh   # Start Saleor and place order via GraphQL
├── s2_to_s4_start_and_place_order_by_storefront.sh # Start all services and place order via Storefront
├── s4_to_s1_stop.sh                                # Stop all services
└── other utility scripts...
```

## Quick Start

**Important**: The steps below must be executed in order. Step 1 (GraphQL API) must be completed before proceeding to Step 2 (Storefront UI), as it initializes necessary data.

### 1. Place Order via GraphQL API

```bash
cd start_saleor

# Start Saleor and place an order using GraphQL API
./s1_start_saleor_and_place_order_by_graphql.sh

# You should see POST notifications in webhook.site
```

This script will:
- Start the Saleor service
- Create a test order using GraphQL API
- Initialize shipping address data for admin@example.com
- Send webhook notifications for order events

### 2. Place Order via Storefront UI 

**Note**: Make sure you have completed Step 1 before proceeding, as it sets up required shipping address data.

```bash
# Start all services and prepare for Storefront order
./s2_to_s4_start_and_place_order_by_storefront.sh

# Visit http://localhost:3000/ to access the Storefront
# Login with admin@example.com/admin
# Purchase the "monospace tee" product
# Shipping address should be auto-populated
```

Note: If you encounter a cookie error when accessing http://localhost:3000/, clear your Chrome browser cache.

You should see webhook POST notifications for the order events.

### 3. Stopping the Services

```bash
cd start_saleor
./s4_to_s1_stop.sh
```

## Troubleshooting

1. Cookie Error
   - If you see a cookie error when accessing the Storefront, clear your Chrome browser cache
   - Then try accessing http://localhost:3000/ again

2. Service Startup
   - The scripts include waiting mechanisms to ensure services are properly started
   - If you encounter any service-related errors, ensure all Docker containers are stopped before retrying

3. Webhook Notifications
   - Webhook notifications can be monitored at webhook.site
   - Ensure you have internet connectivity to receive webhook notifications

## Default Credentials

- Admin Login:
  - Email: admin@example.com
  - Password: admin

## Additional Information

- The GraphQL Playground is available at: http://localhost:8000/graphql/
- The Storefront runs on: http://localhost:3000/
- Webhook notifications are sent to webhook.site for monitoring order events