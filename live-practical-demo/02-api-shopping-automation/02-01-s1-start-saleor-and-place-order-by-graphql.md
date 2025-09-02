# Start Saleor and Place Order by GraphQL

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

14.1 启动 Saleor 服务
- 调用 `s1_start_saleor.sh` 启动 Saleor 服务
- 等待 Saleor GraphQL API (http://localhost:8000/graphql/) 可访问

14.2 设置 Webhook
- 测试 webhook.site 连接
- 获取管理员用户认证 Token
  - 如果管理员用户不存在，自动创建管理员用户
- 创建 App（具有 HANDLE_CHECKOUTS 和 MANAGE_ORDERS 权限）
- 创建 Webhook（订阅 ORDER_CREATED 事件）

14.3 创建订单
- 检查产品数据
  - 如果没有产品数据，自动运行 `populatedb` 命令填充示例数据
- 获取产品 Variant ID
- 创建 Checkout（包含客户信息、产品和地址）
- 设置配送方式
- 使用 App Token 创建订单（触发 Webhook）

14.4 处理订单支付
- 标记订单为已支付
- 验证订单支付状态

14.5 输出执行结果
- 显示所有操作的 ID 和结果
- 提供 Webhook URL 和 GraphQL Playground 链接

## 15. 让AI生成脚本s2_to_s4_start_and_place_order_by_storefront.sh来配置Storefront、dummy payment app和ngrok以便能从Storefront Web UI下单

15.1 初始化和准备
- 定义了各种颜色代码和打印函数，用于输出不同类型的信息（步骤、成功、警告、错误等）
- 定义了 GraphQL 查询函数 [execute_graphql_simple](cci:1://file:///Users/binwu/OOR-local/katas/saleor/start_saleor/s2_to_s4_start_and_place_order_by_storefront.sh:41:0-73:1)，用于与 Saleor API 交互
- 定义了服务等待函数 [wait_for_service](cci:1://file:///Users/binwu/OOR-local/katas/saleor/start_saleor/s2_to_s4_start_and_place_order_by_storefront.sh:76:0-96:1)，用于确保服务已启动

15.2 启动所有服务
- 调用 `./s2_to_s4_start.sh` 脚本启动所有必要的服务

15.3 等待服务启动
- 等待 Saleor GraphQL 服务（端口8000）启动
- 等待 Dummy Payment App（端口3001）启动

15.4 获取 ngrok URL
- 调用 [get_ngrok_url](cci:1://file:///Users/binwu/OOR-local/katas/saleor/start_saleor/s2_to_s4_start_and_place_order_by_storefront.sh:99:0-137:1) 函数获取 ngrok 的公共 URL
- 这个 URL 用于将本地 Dummy Payment App 暴露到互联网

15.5 获取认证令牌
- 调用 [get_auth_token_simple](cci:1://file:///Users/binwu/OOR-local/katas/saleor/start_saleor/s2_to_s4_start_and_place_order_by_storefront.sh:140:0-179:1) 函数获取 Saleor 管理员认证令牌
- 使用固定的管理员账号（admin@example.com/admin）登录

15.6 查找并卸载旧的 Dummy Payment App
- 调用 [get_dummy_app_id](cci:1://file:///Users/binwu/OOR-local/katas/saleor/start_saleor/s2_to_s4_start_and_place_order_by_storefront.sh:182:0-218:1) 函数查找已安装的 Dummy Payment App
- 如果找到，则调用 [uninstall_app](cci:1://file:///Users/binwu/OOR-local/katas/saleor/start_saleor/s2_to_s4_start_and_place_order_by_storefront.sh:221:0-248:1) 函数卸载它

15.7 安装新的 Dummy Payment App
- 调用 [install_app](cci:1://file:///Users/binwu/OOR-local/katas/saleor/start_saleor/s2_to_s4_start_and_place_order_by_storefront.sh:251:0-297:1) 函数，使用之前获取的 ngrok URL 安装新的 Dummy Payment App
- 通过 GraphQL API 发送安装请求，包括必要的权限（HANDLE_PAYMENTS, HANDLE_CHECKOUTS）

15.8 验证安装结果
- 调用 [verify_installation](cci:1://file:///Users/binwu/OOR-local/katas/saleor/start_saleor/s2_to_s4_start_and_place_order_by_storefront.sh:300:0-351:1) 函数检查 Dummy Payment App 是否成功安装并激活

15.9 输出安装信息
- 显示安装成功的消息
- 输出重要信息，包括 ngrok URL、Manifest URL 和 GraphQL Playground 地址

整体来说，这个脚本的主要功能是启动 Saleor 相关服务，并确保 Dummy Payment App 被正确安装和配置，以便通过 Storefront 进行订单支付处理。脚本通过 GraphQL API 自动化了整个安装和配置过程。