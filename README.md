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
├── saleor/                    # Saleor 核心后端 (GraphQL API)
├── saleor-platform/           # Docker 编排平台 (一键启动所有服务)
├── storefront/               # React.js 前端商城
├── dummy-payment-app/        # 测试支付应用
├── start_saleor/            # 数据清理、准备与应用启动脚本
└── ui_testing_for_smoke_and_happy_path/ # UI 测试脚本（待添加）
```

## 各子目录详细说明

### 📦 `saleor/` - 核心后端服务

**网址**: https://github.com/saleor/saleor

**作用**: Saleor 的核心 GraphQL API 后端服务，基于 Django 框架构建的无头电商平台。

**主要特性**:
- **API-first 架构**: 纯 GraphQL API，支持无头电商架构
- **多渠道支持**: 支持多货币、多语言、多仓库
- **企业级功能**: 订单管理、库存管理、支付编排、促销引擎
- **可扩展性**: 通过 webhooks、应用和元数据支持扩展
- **现代技术栈**: Python 3.12 + Django 5.2 + GraphQL

**技术栈**:
- Python 3.12
- Django 5.2 with GraphQL (Graphene)
- PostgreSQL 数据库
- Redis 缓存
- Celery 异步任务处理
- OpenTelemetry 可观测性

**启动方式**:
```bash
cd saleor/
# 使用 Poetry 管理依赖
poetry install
poetry run python manage.py migrate
poetry run python manage.py populatedb --createsuperuser
poetry run poe start  # 启动开发服务器
```

### 🐳 `saleor-platform/` - Docker 编排平台

**网址**: https://github.com/saleor/saleor-platform

**作用**: 提供一键启动所有 Saleor 服务的 Docker Compose 配置，是本地开发的最简单方式。

**包含服务**:
- Saleor Core API (端口 8000)
- Saleor Dashboard 管理后台 (端口 9000)
- PostgreSQL 数据库
- Redis 缓存
- Mailpit 邮件测试界面 (端口 8025)
- Jaeger APM 监控 (端口 16686)

**启动方式**:
```bash
cd saleor-platform/
docker compose run --rm api python3 manage.py migrate
docker compose run --rm api python3 manage.py populatedb --createsuperuser
docker compose up
```

**默认访问地址**:
- API: http://localhost:8000
- 管理后台: http://localhost:9000
- 邮件界面: http://localhost:8025
- APM 监控: http://localhost:16686

### 🛒 `storefront/` - React.js 前端商城

**网址**: https://github.com/saleor/storefront

**作用**: 基于 Next.js 14 和 React 18 构建的现代化电商前端，展示如何与 Saleor API 集成。

**主要特性**:
- **Next.js 15**: App Router、React Server Components、图片优化
- **TypeScript**: 强类型代码和 GraphQL 类型安全
- **现代 UI**: TailwindCSS 样式，响应式设计
- **完整购物流程**: 产品目录、购物车、结账、用户账户
- **支付集成**: 支持 Adyen 和 Stripe 支付

**功能模块**:
- 产品目录和分类浏览
- 变体选择和产品属性
- 单页结账流程
- 用户账户和订单历史
- 优惠券和礼品卡
- SEO 优化

**启动方式**:
```bash
cd storefront/saleor-storefront-installed-manually-from-fork/
pnpm install
pnpm dev  # 访问 http://localhost:3000
```

### 💳 `dummy-payment-app/` - 测试支付应用

**网址**: https://github.com/saleor/dummy-payment-app

**作用**: 用于测试 Saleor 支付和结账功能的虚拟支付应用，无需配置真实支付提供商。

**主要功能**:
- 模拟支付流程（成功/失败/需要验证）
- 支持退款、取消和收费操作
- 提供 Dashboard UI 用于创建和管理交易
- 实现 Saleor 支付 webhooks

**支持的 Webhooks**:
- `PAYMENT_GATEWAY_INITIALIZE_SESSION`
- `TRANSACTION_INITIALIZE_SESSION`
- `TRANSACTION_PROCESS_SESSION`
- `TRANSACTION_REFUND_REQUESTED`
- `TRANSACTION_CHARGE_REQUESTED`
- `TRANSACTION_CANCELATION_REQUESTED`

**启动方式**:
```bash
cd dummy-payment-app/
pnpm install
pnpm dev  # 访问 http://localhost:3000
```

### 🚀 `start_saleor/` - 数据清理、准备与应用启动脚本

**网址**: https://github.com/wubin28/start_saleor

**作用**: 提供一套完整的脚本来演示 Saleor 电商功能，包括通过 GraphQL API 和前端界面下单的完整流程。

**主要脚本**:
- `s1_start_saleor_and_place_order_by_graphql.sh`: 启动 Saleor 并通过 GraphQL API 下单
- `s2_to_s4_start_and_place_order_by_storefront.sh`: 启动所有服务并通过前端下单
- `s4_to_s1_stop.sh`: 停止所有服务

**演示流程**:
1. **GraphQL API 下单**: 直接调用 API 创建订单，初始化配送地址
2. **前端界面下单**: 通过浏览器访问商城完成购买流程
3. **端到端测试**: 使用 Playwright 自动化测试完整购物流程

**使用方式**:
```bash
cd start_saleor/
# 步骤1: GraphQL API 下单
./s1_start_saleor_and_place_order_by_graphql.sh

# 步骤2: 前端界面下单 (需要先完成步骤1)
./s2_to_s4_start_and_place_order_by_storefront.sh

# 停止所有服务
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