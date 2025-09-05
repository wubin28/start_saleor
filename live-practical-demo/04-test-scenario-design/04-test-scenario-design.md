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
