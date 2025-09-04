# Saleor电商系统氛围编程测试用例设计

## 1. 测试用例设计

### 1.1 冒烟测试用例（Web UI技术栈）

#### 冒烟测试用例组1：系统基础功能验证
```
Given: Saleor平台已启动并运行在localhost:3000
When: 访问storefront首页
Then: 页面应成功加载且显示产品列表

Given: storefront首页已加载
When: 点击任意产品
Then: 产品详情页应正确显示产品信息和价格

Given: 用户在产品详情页
When: 选择产品规格并点击"Add to Cart"
Then: 购物车图标应显示商品数量更新

Given: 购物车已添加商品
When: 点击购物车图标
Then: 购物车页面应显示已添加的商品

Given: 用户在购物车页面
When: 点击"Checkout"按钮
Then: Checkout页面应成功加载
```

### 1.2 Happy Path测试用例（Web UI技术栈）

#### 完整购物流程测试用例
```
Given: Saleor平台已启动，数据库已填充示例数据，用户admin@example.com已创建
  And: storefront运行在localhost:3000
  And: 用户未登录状态

When: 用户访问storefront首页
Then: 页面应显示产品列表，包含"Monospace Tee"产品

When: 用户点击"Monospace Tee"产品
Then: 产品详情页应显示产品信息、价格和规格选择

When: 用户选择"S"号规格
  And: 点击"Add to Cart"按钮
Then: 购物车图标应显示数字"1"
  And: 页面应显示商品已添加到购物车的确认信息

When: 用户点击购物车图标
Then: 购物车页面应显示"Monospace Tee"商品
  And: 数量显示为1
  And: 显示正确的价格信息

When: 用户点击"Checkout"按钮
Then: Checkout页面应成功加载
  And: 显示"Sign in"链接

When: 用户点击"Sign in"链接
  And: 输入邮箱"admin@example.com"和密码"admin"
  And: 点击登录按钮
Then: 用户应成功登录
  And: 自动返回到Checkout页面
  And: "Sign in"链接变为"Sign out"

When: Checkout页面重新加载后
Then: "Shipping address"下方应显示"Jane Smith"的送货地址并自动选中
  And: "Use shipping address as billing address"应自动勾选
  And: "Delivery methods"下方的"Default"应自动选中
  And: 右侧"Summary"区域应显示"Monospace Tee"
  And: "Quantity"输入框显示数字1
  And: 单价显示为"$20.00"
  And: "Total price"显示为"$20.00"

When: 用户点击"Make payment and create order"按钮
Then: 页面应显示"Order #XX confirmed"确认信息
  And: 订单应成功创建
```

### 1.3 Sad Path测试用例（GraphQL API技术栈）

#### 测试用例组1：认证失败场景
```
Given: Saleor GraphQL API运行在localhost:8000/graphql/
When: 发送tokenCreate mutation使用错误的邮箱"wrong@example.com"和密码"wrong"
Then: 响应应包含错误信息"Please, enter valid credentials"
  And: token字段应为null或未定义
```

#### 测试用例组2：订单创建失败场景
```
Given: 用户已获得有效的认证token
  And: 没有任何产品存在于数据库中
When: 发送products查询请求
Then: 响应的products.edges数组应为空
  And: 无法获取到有效的variant ID

Given: 用户尝试创建checkout但使用无效的variant ID
When: 发送checkoutCreate mutation使用不存在的variantId
Then: 响应应包含错误信息
  And: checkout创建应失败
```

#### 测试用例组3：支付处理失败场景
```
Given: 用户已创建有效的checkout
  And: 已获得App token
When: 发送orderCreateFromCheckout mutation但checkout ID不存在
Then: 响应应包含错误信息
  And: 订单创建应失败

Given: 订单已创建但使用无效的order ID
When: 发送orderMarkAsPaid mutation使用不存在的订单ID
Then: 响应应包含错误信息
  And: 支付状态更新应失败
```

#### 测试用例组4：权限验证失败场景
```
Given: 用户使用过期或无效的token
When: 发送任何需要认证的GraphQL mutation
Then: 响应应返回认证错误
  And: 操作应被拒绝

Given: 用户使用User token尝试执行需要App权限的操作
When: 发送orderCreateFromCheckout mutation使用User token而非App token
Then: 响应应包含权限错误
  And: 操作应失败
```

## 2. 2025年主流测试技术栈推荐

### 2.1 方案1：Playwright + Jest + GraphQL-Request
**Web UI测试：**
- **Playwright**: 现代化的端到端测试框架，支持多浏览器，具有优秀的调试能力
- **TypeScript**: 强类型支持，提高代码质量
- **Jest**: 成熟的测试运行器和断言库

**GraphQL API测试：**
- **graphql-request**: 轻量级GraphQL客户端
- **Jest**: 统一的测试框架
- **nock**: 网络请求mock

**优势：**
- Playwright是微软开发的现代化测试框架，性能优秀
- 支持并行测试和重试机制
- 内置视频录制和截图功能
- 强大的调试工具

### 2.2 方案2：Cypress + Vitest + Apollo Client
**Web UI测试：**
- **Cypress**: 流行的端到端测试框架，开发者体验优秀
- **Cypress Testing Library**: 提供更好的元素查找方法

**GraphQL API测试：**
- **Apollo Client**: 功能强大的GraphQL客户端
- **Vitest**: 现代化的测试框架，Vite生态系统
- **MSW (Mock Service Worker)**: 现代化的API mocking

**优势：**
- Cypress具有优秀的实时调试能力
- Vitest启动速度快，支持热重载
- MSW提供更真实的网络mock体验

### 2.3 方案3：WebdriverIO + Mocha + urql
**Web UI测试：**
- **WebdriverIO**: 成熟稳定的WebDriver实现
- **Mocha**: 灵活的测试框架
- **Chai**: 丰富的断言库

**GraphQL API测试：**
- **urql**: 轻量级GraphQL客户端
- **Mocha**: 统一测试框架
- **Sinon**: 强大的测试替身库

**优势：**
- WebdriverIO生态系统成熟，插件丰富
- 支持多种浏览器和移动端测试
- 企业级项目验证


## 3. 最终推荐：方案1 - Playwright + Jest + GraphQL-Request

### 推荐理由：

1. **技术前瞻性**：Playwright是2025年最现代化的E2E测试框架，由微软开发维护，技术架构先进

2. **性能优势**：
   - 并行测试执行，大幅提升测试速度
   - 自动等待机制，减少flaky测试
   - 内置重试机制，提高测试稳定性

3. **调试友好**：
   - 内置trace viewer，可视化测试执行过程
   - 自动截图和视频录制
   - 支持断点调试和交互式模式

4. **生态系统完整**：
   - Jest作为业界标准测试框架，文档丰富
   - graphql-request轻量级但功能完备
   - TypeScript原生支持，类型安全

5. **维护成本低**：
   - API稳定，向后兼容性好
   - 社区活跃，问题解决迅速
   - 配置简单，学习曲线平缓

6. **适合Saleor项目**：
   - 支持Next.js应用测试
   - GraphQL测试支持完善
   - 可以很好地处理复杂的电商购物流程

7. **企业级特性**：
   - 支持CI/CD集成
   - 详细的测试报告
   - 支持多环境配置

这个技术栈组合既满足了2025年的技术趋势，又能有效支撑Saleor电商平台的复杂测试需求，是最佳的选择。