# Place Order by GraphQL API and Storefront Web UI

## 1. 用AI生成脚本s1_start_saleor.sh

## 2. 用AI生成脚本s1_stop_saleor.sh

## 3. 用AI生成脚本s2_start_storefront.sh

这个脚本是一个自动化脚本，用于启动 Saleor 的前端商店（storefront）。按时间顺序，它完成以下功能：

3.1 **打开新的 iTerm2 窗口**
   - 使用 osascript 和 AppleScript 激活 iTerm2 应用
   - 创建一个带有默认配置的新窗口

3.2 **切换到 Saleor 前端项目目录**
   - 导航到 `/Users/binwu/OOR-local/katas/saleor/storefront/saleor-storefront-installed-manually-from-fork` 目录
   - 等待 0.5 秒确保命令执行完成

3.3 **安装项目依赖**
   - 执行 `pnpm install` 命令安装前端项目所需的所有依赖包
   - 等待 2 秒确保安装过程有足够时间启动

3.4 **启动开发服务器**
   - 执行 `pnpm run dev` 命令启动前端开发服务器
   - 这会在开发模式下运行 Saleor 的前端商店应用

## 4. 用AI生成脚本s2_stop_storefront.sh

## 5. 用AI生成脚本s3_start_dummy_payment_app.sh

5.1 **启动 iTerm2 应用程序**
   - 使用 `osascript` 执行 AppleScript 命令
   - 激活 iTerm2 应用程序 (`activate`)

5.2 **创建新的 iTerm2 窗口**
   - 使用默认配置文件创建新窗口 (`create window with default profile`)

5.3 **切换工作目录**
   - 在新窗口中执行命令 `cd /Users/binwu/OOR-local/katas/saleor/dummy-payment-app`
   - 将工作目录切换到 dummy-payment-app 目录

5.4 **等待命令执行完成**
   - 脚本暂停 0.5 秒 (`delay 0.5`)，确保目录切换命令执行完成

5.5 **启动 dummy payment 应用**
   - 执行命令 `pnpm run dev --port 3001`
   - 在端口 3001 上启动 dummy payment 应用

## 6. 用AI生成脚本s3_stop_dummy_payment_app.sh

## 7. 用AI生成脚本s4_start_ngrok.sh

7.1 调用 osascript 执行 AppleScript 命令（第6-19行）：
   - 激活 iTerm2 应用程序（第8行）
   - 创建一个新的 iTerm2 窗口，使用默认配置文件（第11行）
   - 获取当前窗口的当前会话（第14行）
   - 在该会话中执行命令 `ngrok http 3001`（第16行）

这个脚本的主要目的是通过 ngrok 工具将本地运行在 3001 端口的服务（dummy payment app）暴露到公网，使外部服务能够访问本地开发环境。

## 8. 用AI生成脚本s4_stop_ngrok.sh

## 9. 用AI生成脚本s1_to_s4_start.sh

## 10. 用AI生成脚本s4_to_s1_stop.sh

## 11. 用AI生成脚本s1_to_s4_start_and_reinstall_dummy_payment_app.sh

11.1 启动所有服务（第361-368行）
- 调用 `./s1_to_s4_start.sh` 启动所有服务
- 等待 Saleor GraphQL 服务（端口8000）启动
- 等待 Dummy Payment App 服务（端口3001）启动

11.2 获取 ngrok URL（第369-374行）
- 从 ngrok API 获取转发 URL（用于外部访问 Dummy Payment App）
- 确保获取到的是转发到 localhost:3001 的 HTTPS URL

11.3 获取 Saleor 认证 token（第376-381行）
- 使用 GraphQL API 获取管理员认证 token
- 使用默认凭据：admin@example.com / admin

11.4 查找并卸载旧的 Dummy Payment App（第383-390行）
- 通过 GraphQL API 查询已安装的应用
- 如果找到 Dummy Payment App，获取其 ID
- 使用 appDelete mutation 卸载旧应用

11.5 安装新的 Dummy Payment App（第392-395行）
- 使用 appInstall mutation 安装新应用
- 提供 manifest URL（ngrok URL + /api/manifest）
- 设置必要的权限（HANDLE_PAYMENTS, HANDLE_CHECKOUTS）

11.6 验证安装结果（第397-406行）
- 检查应用是否成功安装并激活
- 如果未在已安装应用中找到，检查安装状态
- 显示安装信息（ngrok URL、Manifest URL、GraphQL Playground URL）

## 12. 让AI修改脚本s1_start_saleor.sh以便清空数据、执行数据库迁移、导入数据、创建超级用户、启动 Saleor

这个脚本通过 AppleScript 自动化打开一个新的 iTerm2 窗口并按顺序执行以下操作：

12.1 **环境准备**：
   * 打开新的 iTerm2 窗口
   * 切换到 Saleor 平台目录 (`/Users/binwu/OOR-local/katas/saleor/saleor-platform`)

12.2 **清理现有环境**：
   * 执行 `docker compose down` 停止所有运行中的容器
   * 执行 `docker compose down -v` 删除所有数据卷以彻底清空数据

12.3 **初始化数据库**：
   * 执行数据库迁移 `docker compose run --rm api python3 manage.py migrate`
   * 执行系统设置 `docker compose run --rm api python3 manage.py setup`
   * 填充示例数据 `docker compose run --rm api python3 manage.py populatedb`

12.4 **创建管理员账户**：
   * 创建超级用户，用户名为 `admin`，邮箱为 `admin@example.com`，密码为 `admin`

12.5 **启动应用**：
   * 执行 `docker compose up` 启动所有服务

## 13. 让AI（windsurf搭配Claude Sonnet 3.7大模型）在s1_to_s4_start_and_reinstall_dummy_payment_app.sh中添加用GraphQL API下单的脚本（参见02-02-13-place-order-by-graphql-api.md中的提示词）

## 14. 让AI（windsurf搭配Claude Sonnet 3.7大模型）将s1_to_s4_start_and_reinstall_dummy_payment_app.sh中的用GraphQL API下单的脚本提取到另一个脚本文件s1_start_saleor_and_place_order_by_graphql.sh中（参见02-03-14-move-order-placement-logic.md中的提示词）


```markdown
12.1 启动Saleor服务

12.2 获取用户认证Token

12.3 创建App

12.4 创建Webhook

12.5 获取产品信息

12.6 创建完整的Checkout

12.7 设置配送方式

12.8 创建订单并触发Webhook

12.9 标记订单为已支付

12.10 验证支付状态

12.11 执行总结
```

### 初始化阶段
```bash
local WEBHOOK_URL="https://webhook.site/99475069-12a9-4a24-8952-b3246f7ca573"
```
设置用于接收订单事件通知的Webhook URL。

### 第0步：启动Saleor服务
```bash
print_step "0" "启动 Saleor 服务"
./s1_start_saleor.sh  # 如果文件存在则执行
```
- 调用外部脚本启动Saleor后端服务
- 如果启动脚本不存在，假设服务已经在运行

### 第1步：等待服务启动并测试连接
```bash
wait_for_service "http://localhost:8000/graphql/" "Saleor GraphQL"
test_webhook_connection "$WEBHOOK_URL"
```
- **等待GraphQL服务**：循环检测GraphQL端点是否可访问（最多30次，每次间隔2秒）
- **测试Webhook连接**：向webhook.site发送测试POST请求，验证连接是否正常

### 第2步：认证和权限设置 (Step 1: Add Webhook)

#### 2.1 获取用户认证Token
```bash
AUTH_TOKEN=$(get_auth_token_simple)
```
- 使用管理员账号（admin@example.com/admin）执行`tokenCreate` mutation
- 如果认证失败，自动创建管理员用户后重试
- 返回用于后续API调用的认证token

#### 2.2 创建App
```bash
APP_RESULT=$(create_app "$AUTH_TOKEN")
APP_ID="${APP_RESULT%|*}"
APP_TOKEN="${APP_RESULT#*|}"
```
- 创建名为"My App"的应用
- 授予`HANDLE_CHECKOUTS`和`MANAGE_ORDERS`权限
- 返回App ID和App Token（用于订单操作）

#### 2.3 创建Webhook
```bash
WEBHOOK_ID=$(create_webhook "$AUTH_TOKEN" "$APP_ID" "$WEBHOOK_URL")
```
- 为App创建Webhook，监听`ORDER_CREATED`事件
- 当订单创建时，Saleor会向指定URL发送POST通知
- 验证Webhook配置是否正确

### 第3步：订单创建流程 (Step 2: Create an Order)

#### 3.1 获取产品信息
```bash
VARIANT_ID=$(get_product_variant "$AUTH_TOKEN")
```
- 查询前5个产品及其变体信息
- 如果没有产品数据，自动运行`populatedb`命令填充示例数据
- 返回第一个可用的产品变体ID

#### 3.2 创建完整的Checkout
```bash
CHECKOUT_RESULT=$(create_checkout "$AUTH_TOKEN" "$VARIANT_ID")
CHECKOUT_ID="${CHECKOUT_RESULT%|*}"
SHIPPING_METHOD_ID="${CHECKOUT_RESULT#*|}"
```
- 创建包含完整信息的购物车：
  - 产品：1个指定变体的商品
  - 客户邮箱：webhook-test@example.com
  - 账单地址：洛杉矶的虚拟地址
  - 配送地址：与账单地址相同
- 返回Checkout ID和可用的配送方式ID

#### 3.3 设置配送方式
```bash
set_shipping_method "$AUTH_TOKEN" "$CHECKOUT_ID" "$SHIPPING_METHOD_ID"
```
- 为checkout设置配送方式
- 更新总价格（包含配送费用）

#### 3.4 创建订单并触发Webhook
```bash
ORDER_ID=$(create_order_from_checkout "$APP_TOKEN" "$CHECKOUT_ID")
```
- **切换到App Token**：使用App权限而非用户权限
- 从checkout创建正式订单
- **触发Webhook**：订单创建成功后，Saleor自动向webhook.site发送ORDER_CREATED事件
- 等待5秒让webhook有时间触发

### 第4步：支付处理 (Step 3: Mark Order as Paid)

#### 4.1 标记订单为已支付
```bash
mark_order_paid "$APP_TOKEN" "$ORDER_ID"
```
- 使用App Token将订单状态更改为已支付
- 模拟支付完成的场景

#### 4.2 验证支付状态
```bash
verify_payment_status "$APP_TOKEN" "$ORDER_ID"
```
- 查询订单详情确认支付状态
- 检查`paymentStatus`、`authorizeStatus`、`chargeStatus`等字段

### 第5步：执行总结
脚本最后输出完整的操作总结：
```bash
echo -e "📋 操作总结:"
echo -e "   • ✅ 用户认证Token获取成功"
echo -e "   • ✅ App创建成功 (ID: $APP_ID)"
echo -e "   • ✅ Webhook创建成功 (ID: $WEBHOOK_ID)"
echo -e "   • ✅ 产品Variant获取成功 (ID: $VARIANT_ID)"
echo -e "   • ✅ Checkout创建成功 (ID: $CHECKOUT_ID)"
echo -e "   • ✅ 订单创建成功 (ID: $ORDER_ID)"
echo -e "   • ✅ 订单支付标记完成"
```

## 核心功能总结

1. **服务启动与连接测试**：确保Saleor后端服务和Webhook服务都可用
2. **权限管理**：建立完整的认证和授权体系（用户Token + App Token）
3. **Webhook集成**：配置订单事件的实时通知机制
4. **电商流程自动化**：完整模拟从商品选择到支付完成的购物流程
5. **错误处理**：包含自动重试、数据填充等容错机制

这个脚本实现了一个完整的Saleor电商平台GraphQL API的自动化测试流程，涵盖了认证、商品管理、订单处理、支付和事件通知等核心功能。

## 15. 让AI生成脚本s2_to_s4_start_and_place_order_by_storefront.sh来配置Storefront、dummy payment app和ngrok以便能从Storefront Web UI下单

```markdown
15.1 启动storefront、dummy payment app和ngrok

15.2 等待服务启动

15.3 获取ngrok forwarding URL

15.4 获取用户认证token

15.5 查找并卸载旧的Dummy Payment App

15.6 安装新的Dummy Payment App

15.7 验证安装结果

15.8 输出安装总结
```

### 第1步：启动所有服务
```bash
print_step "1" "启动所有服务"
./s2_to_s4_start.sh
```
- 调用外部脚本启动完整的服务栈
- 预计包括：Saleor后端、Storefront前端、Dummy Payment App、ngrok隧道服务

### 第2步：等待服务完全启动
```bash
print_step "2" "等待服务完全启动"
wait_for_service "http://localhost:8000/graphql/" "Saleor GraphQL"
wait_for_service "http://localhost:3001/api/manifest" "Dummy Payment App"
```
- **等待Saleor GraphQL服务**：循环检测GraphQL API端点是否可访问（最多30次，每次间隔2秒）
- **等待Dummy Payment App服务**：检测支付应用的manifest端点是否响应
- 确保核心服务都已启动并可用

### 第3步：获取ngrok forwarding URL
```bash
print_step "3" "获取 ngrok forwarding URL"
NGROK_URL=$(get_ngrok_url)
```
- **查询ngrok API**：向 `http://localhost:4040/api/tunnels` 发送请求
- **筛选HTTPS隧道**：查找指向 `http://localhost:3001` 的HTTPS隧道
- **获取公网URL**：提取可从外网访问的URL（如：`https://abc123.ngrok.io`）
- **生成manifest URL**：自动构建 `${ngrok_url}/api/manifest` 用于应用安装

### 第4步：获取认证token
```bash
print_step "4" "获取认证 token"
AUTH_TOKEN=$(get_auth_token_simple)
```
- 使用管理员凭据（admin@example.com/admin）执行 `tokenCreate` mutation
- 直接使用硬编码的JSON payload，确保认证成功
- 返回用于后续GraphQL API调用的Bearer token

### 第5步：查找并卸载旧的Dummy Payment App
```bash
print_step "5" "查找并卸载旧的 Dummy Payment App"
DUMMY_APP_ID=$(get_dummy_app_id "$AUTH_TOKEN")
if [ -n "$DUMMY_APP_ID" ]; then
    uninstall_app "$AUTH_TOKEN" "$DUMMY_APP_ID"
    sleep 3
else
    print_info "未找到旧应用，跳过卸载"
fi
```
- **查询已安装应用**：使用 `apps` query 获取所有应用列表
- **查找Dummy Payment App**：在应用名称中搜索包含 "Dummy Payment App" 的应用
- **执行卸载操作**：如果找到旧版本，使用 `appDelete` mutation 卸载
- **等待卸载完成**：sleep 3秒确保卸载操作完全生效
- **处理无旧应用情况**：如果没有找到旧应用，跳过卸载步骤

### 第6步：安装新的Dummy Payment App
```bash
print_step "6" "安装新的 Dummy Payment App"
install_app "$AUTH_TOKEN" "$NGROK_URL"
```
- **构建manifest URL**：使用ngrok URL + `/api/manifest`
- **执行应用安装**：调用 `appInstall` mutation，参数包括：
  - `appName`: "Dummy Payment App"
  - `manifestUrl`: 从ngrok获取的manifest地址
  - `permissions`: `[HANDLE_PAYMENTS, HANDLE_CHECKOUTS]`
- **检查安装状态**：验证返回的 `appInstallation` 对象和状态
- **等待安装处理**：sleep 5秒让安装过程完成

### 第7步：验证安装结果
```bash
print_step "7" "验证安装结果"
verify_installation "$AUTH_TOKEN"
```
- **查询已安装应用**：重新获取应用列表确认安装成功
- **检查应用状态**：验证应用的 `isActive` 状态
- **备用验证方法**：如果在 `apps` 中找不到，查询 `appInstallations`
- **状态判断**：
  - `PENDING`: 安装中
  - `INSTALLED`: 安装完成
  - `isActive: true`: 应用已激活

### 第8步：输出安装总结
```bash
print_success "🎉 Dummy Payment App 重新安装完成！"
echo -e "📋 安装信息:"
echo -e "   • ngrok URL: $NGROK_URL"
echo -e "   • Manifest URL: $NGROK_URL/api/manifest"
echo -e "   • GraphQL Playground: http://localhost:8000/graphql/"
```

## 核心功能总结

### 1. **服务编排管理**
- 统一启动多个相关服务（Saleor + Storefront + Payment App + ngrok）
- 智能等待所有依赖服务就绪

### 2. **网络隧道集成**
- 自动获取ngrok公网URL
- 解决本地支付应用需要外网访问的问题
- 动态构建manifest URL

### 3. **应用生命周期管理**
- **查找**：智能检测已存在的支付应用
- **卸载**：清理旧版本避免冲突
- **安装**：使用最新的manifest重新安装
- **验证**：确保安装成功和应用状态正常

### 4. **权限和认证处理**
- 获取管理员权限token
- 为支付应用分配必要权限（`HANDLE_PAYMENTS`, `HANDLE_CHECKOUTS`）

### 5. **错误处理和容错**
- 每个步骤都有失败检测
- 智能跳过不存在的旧应用
- 提供详细的调试信息

## 与第一个脚本的区别

| 功能对比 | s1_start_saleor_and_place_order_by_graphql.sh | s2_to_s4_start_and_place_order_by_storefront.sh |
|---------|-----------------------------------------------|------------------------------------------------|
| **主要目的** | GraphQL API自动化下单测试 | 支付应用重新安装和配置 |
| **服务范围** | 仅Saleor后端 + Webhook | 完整技术栈（前后端+支付+隧道） |
| **核心操作** | 创建订单、设置webhook、模拟支付 | 应用生命周期管理、网络配置 |
| **外部依赖** | webhook.site | ngrok隧道服务 |
| **适用场景** | API集成测试 | 支付功能端到端测试准备 |

这个脚本主要是为后续的Storefront前端购物流程做准备，确保支付应用正确安装并可以处理来自公网的支付回调。