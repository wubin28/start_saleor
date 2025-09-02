# Saleor E-commerce Demo

This project provides a set of scripts to demonstrate Saleor e-commerce functionality, including order placement through both GraphQL API and Storefront UI.

## Prerequisites

- macOS (tested on Sequoia 15.6)
- Docker and Docker Compose
- Python 3
- curl
- Chrome browser
- Node.js with npm/npx (for end-to-end testing)
- Playwright for end-to-end testing

## Project Structure in Parent Directory

```
saleor/
├── saleor/                    # Saleor core backend (GraphQL API)
├── saleor-platform/           # Docker orchestration platform (one-click service startup)
├── storefront/               # React.js frontend store
├── dummy-payment-app/        # Test payment application
├── start_saleor/            # Data cleanup, preparation and application startup scripts
└── ui_testing_for_smoke_and_happy_path/ # UI testing scripts (to be added)
```

## Detailed Description of Each Subdirectory

### 📦 `saleor/` - Core Backend Service

**Website**: https://github.com/saleor/saleor

**Purpose**: Saleor's core GraphQL API backend service, a headless e-commerce platform built on the Django framework.

**Key Features**:
- **API-first Architecture**: Pure GraphQL API, supporting headless e-commerce architecture
- **Multi-channel Support**: Supports multiple currencies, languages, and warehouses
- **Enterprise Features**: Order management, inventory management, payment orchestration, promotion engine
- **Extensibility**: Supports extensions through webhooks, apps, and metadata
- **Modern Tech Stack**: Python 3.12 + Django 5.2 + GraphQL

**Tech Stack**:
- Python 3.12
- Django 5.2 with GraphQL (Graphene)
- PostgreSQL database
- Redis cache
- Celery asynchronous task processing
- OpenTelemetry observability

**Startup Method**:
```bash
cd saleor/
# Using Poetry for dependency management
poetry install
poetry run python manage.py migrate
poetry run python manage.py populatedb --createsuperuser
poetry run poe start  # Start development server
```

### 🐳 `saleor-platform/` - Docker Orchestration Platform

**Website**: https://github.com/saleor/saleor-platform

**Purpose**: Provides Docker Compose configuration for one-click startup of all Saleor services, the simplest way for local development.

**Included Services**:
- Saleor Core API (port 8000)
- Saleor Dashboard admin backend (port 9000)
- PostgreSQL database
- Redis cache
- Mailpit email testing interface (port 8025)
- Jaeger APM monitoring (port 16686)

**Startup Method**:
```bash
cd saleor-platform/
docker compose run --rm api python3 manage.py migrate
docker compose run --rm api python3 manage.py populatedb --createsuperuser
docker compose up
```

**Default Access URLs**:
- API: http://localhost:8000
- Admin dashboard: http://localhost:9000
- Email interface: http://localhost:8025
- APM monitoring: http://localhost:16686

### 🛒 `storefront/` - React.js Frontend Store

**Website**: https://github.com/saleor/storefront

**Purpose**: A modern e-commerce frontend built with Next.js 14 and React 18, demonstrating integration with the Saleor API.

**Key Features**:
- **Next.js 15**: App Router, React Server Components, image optimization
- **TypeScript**: Strong typing and GraphQL type safety
- **Modern UI**: TailwindCSS styling, responsive design
- **Complete Shopping Flow**: Product catalog, cart, checkout, user accounts
- **Payment Integration**: Support for Adyen and Stripe payments

**Functional Modules**:
- Product catalog and category browsing
- Variant selection and product attributes
- Single-page checkout process
- User accounts and order history
- Coupons and gift cards
- SEO optimization

**Startup Method**:
```bash
cd storefront/saleor-storefront-installed-manually-from-fork/
pnpm install
pnpm dev  # Access at http://localhost:3000
```

### 💳 `dummy-payment-app/` - Test Payment Application

**Website**: https://github.com/saleor/dummy-payment-app

**Purpose**: A virtual payment application for testing Saleor payment and checkout functionality without configuring real payment providers.

**Main Functions**:
- Simulate payment processes (success/failure/verification required)
- Support refund, cancellation, and charge operations
- Provide Dashboard UI for creating and managing transactions
- Implement Saleor payment webhooks

**Supported Webhooks**:
- `PAYMENT_GATEWAY_INITIALIZE_SESSION`
- `TRANSACTION_INITIALIZE_SESSION`
- `TRANSACTION_PROCESS_SESSION`
- `TRANSACTION_REFUND_REQUESTED`
- `TRANSACTION_CHARGE_REQUESTED`
- `TRANSACTION_CANCELATION_REQUESTED`

**Startup Method**:
```bash
cd dummy-payment-app/
pnpm install
pnpm dev  # Access at http://localhost:3000
```

### 🚀 `start_saleor/` - Data Cleanup, Preparation and Application Startup Scripts

**Website**: https://github.com/wubin28/start_saleor

**Purpose**: Provides a complete set of scripts to demonstrate Saleor e-commerce functionality, including the full process of order placement through both GraphQL API and frontend interface.

**Main Scripts**:
- `s1_start_saleor_and_place_order_by_graphql.sh`: Start Saleor and place an order via GraphQL API
- `s2_to_s4_start_and_place_order_by_storefront.sh`: Start all services and place an order via frontend
- `s4_to_s1_stop.sh`: Stop all services

**Demo Process**:
1. **GraphQL API Order**: Directly call API to create an order, initialize shipping address
2. **Frontend Interface Order**: Complete purchase process through browser
3. **End-to-end Testing**: Automate testing of complete shopping flow with Playwright

**Usage Method**:
```bash
cd start_saleor/
# Step 1: GraphQL API Order
./s1_start_saleor_and_place_order_by_graphql.sh

# Step 2: Frontend Interface Order (must complete Step 1 first)
./s2_to_s4_start_and_place_order_by_storefront.sh

# Stop all services
./s4_to_s1_stop.sh
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

### 3. Run End-to-End Tests

After completing steps 1 and 2, you can run the end-to-end tests to verify the entire flow:

```bash
# Navigate to the E2E test directory
cd ../e2e_testing_for_saleor_happy_path

# Run the end-to-end tests using Playwright
npx playwright test tests/production-ready.spec.ts --project=chromium
```

### 4. Stopping the Services

When you're done with testing, stop all services:

```bash
cd ../start_saleor
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