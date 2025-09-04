# Move Order Placement Logic

Me to Cursor with Claude Sonnet 4:
```markdown
请参考 @s1_to_s4_start_and_reinstall_dummy_payment_app.sh  ，然后创建一个名为“s1_start_saleor_and_place_order_by_graphql.sh”的新脚本，将以下手工操作转为脚本并添加进去，要求每执行一个graphql，都要在终端输出日志，以便跟踪和调试。另外，webhook.site url是 https://webhook.site/99475069-12a9-4a24-8952-b3246f7ca573。下面是手工操作：【
## 🔧 第一步：Add Webhook

### 1.1 获取用户认证Token
```graphql
mutation GetUserToken {
  tokenCreate(email: "admin@example.com", password: "admin") {
    token
    user {
      email
      isStaff
    }
    errors {
      message
    }
  }
}
```

**HTTP Headers设置:**
```json
{
  "Authorization": "Bearer 返回的用户token"
}
```

### 1.2 创建App
```graphql
mutation CreateApp {
  appCreate(input: {
    name: "My App",
    permissions: [HANDLE_CHECKOUTS, MANAGE_ORDERS]
  }) {
    app {
      id
      name
      tokens {
        authToken
      }
    }
    authToken
    errors {
      field
      message
    }
  }
}
```

**1.2 创建App记录返回的:**
- `app.id` (例如: QXBwOjE=)
QXBwOjM=
- `authToken` (完整的App Token)
06XcOGgxHijyXcbCj8eJSKt3z7klm5

### 1.3 创建Webhook（重要：包含ORDER_CREATED事件）
```graphql
mutation CreateWebhook {
  webhookCreate(input: {
    name: "Order webhook",
    targetUrl: "您的webhook.site_URL",
    app: "步骤1.2返回的app.id",
    events: [ORDER_CREATED],
    isActive: true
  }) {
    webhook {
      id
      name
      targetUrl
      isActive
      events {
        eventType
      }
    }
    errors {
      field
      message
    }
  }
}
```

---

## 🛒 第二步：Create an Order

### 2.1 获取产品Variant ID
**继续使用用户token**
```graphql
query GetProducts {
  products(first: 5) {
    edges {
      node {
        id
        name
        variants {
          id
          name
          pricing {
            price {
              gross {
                amount
                currency
              }
            }
          }
        }
      }
    }
  }
}
```

**2.1 获取Monospace Tee产品S号码返回的第一个variant ID** (例如: UHJvZHVjdFZhcmlhbnQ6MzM4)
UHJvZHVjdFZhcmlhbnQ6MzQ4

### 2.2 创建完整的Checkout
```graphql
mutation CreateCompleteCheckout {
  checkoutCreate(input: {
    channel: "default-channel",
    email: "webhook-test@example.com",
    lines: [
      {
        quantity: 1,
        variantId: "步骤2.1返回的variant_ID"
      }
    ],
    billingAddress: {
      firstName: "Jane",
      lastName: "Smith",
      streetAddress1: "456 Oak St",
      city: "Los Angeles", 
      postalCode: "90210",
      country: US,
      countryArea: "CA"
    },
    shippingAddress: {
      firstName: "Jane",
      lastName: "Smith",
      streetAddress1: "456 Oak St",
      city: "Los Angeles",
      postalCode: "90210", 
      country: US,
      countryArea: "CA"
    }
  }) {
    checkout {
      id
      totalPrice {
        gross {
          amount
          currency
        }
      }
      availableShippingMethods {
        id
        name
        price {
          amount
        }
      }
    }
    errors {
      field
      message
    }
  }
}
```

**2.2 创建完整的Checkout 记录返回的:**
- `checkout.id`
Q2hlY2tvdXQ6MzRjZjViMWItZmQwNi00OWI4LTkzMzctMGQxY2ZmZjk1NjUx
- 第一个 `availableShippingMethods.id`
U2hpcHBpbmdNZXRob2Q6MQ==

### 2.3 设置配送方式
```graphql
mutation SetShippingMethod {
  checkoutShippingMethodUpdate(
    id: "步骤2.2返回的checkout.id",
    shippingMethodId: "步骤2.2返回的第一个shipping_method_id"
  ) {
    checkout {
      id
      shippingMethod {
        name
      }
      totalPrice {
        gross {
          amount
          currency
        }
      }
    }
    errors {
      field
      message
    }
  }
}
```

### 2.4 创建订单并触发Webhook
**切换到App Token:**
```json
{
  "Authorization": "Bearer 步骤1.2返回的完整App_Token"
}
```

```json
{
  "Authorization": "Bearer vFGoVIgiC7PAWTTokctJgGgCH3MS1B"
}
```

```graphql
mutation CreateOrderAndTriggerWebhook {
  orderCreateFromCheckout(
    id: "步骤2.2返回的checkout.id"
  ) {
    order {
      id
      number
      status
      total {
        gross {
          amount
          currency
        }
      }
      user {
        email
      }
      created
    }
    errors {
      field
      message
    }
  }
}
```

**2.4 创建订单并触发Webhook 记录返回的 `order.id`**
T3JkZXI6ZDU2NjE5ZWUtZGY0Yy00MzU4LThhZWItYWQ1MDczODk2Mzg4

**立即检查webhook.site**: 应该看到新的POST请求包含订单数据

---

## 💰 第三步：Mark Order as Paid

### 3.1 标记订单为已支付
**继续使用App Token**
```graphql
mutation MarkOrderAsPaid {
  orderMarkAsPaid(
    id: "步骤2.4返回的order.id"
  ) {
    order {
      id
      number
      status
      paymentStatus
      totalBalance {
        amount
        currency
      }
      total {
        gross {
          amount
          currency
        }
      }
      authorizeStatus
      chargeStatus
    }
    errors {
      field
      message
    }
  }
}
```

### 3.2 验证支付状态
```graphql
query CheckOrderStatus {
  order(id: "步骤2.4返回的order.id") {
    id
    number
    status
    paymentStatus
    authorizeStatus
    chargeStatus
    totalBalance {
      amount
      currency
    }
    total {
      gross {
        amount
        currency
      }
    }
    created
    updatedAt
  }
}
```】
```

Cursor with Claude Sonnet 4:

```markdown
我将基于参考脚本创建一个新的脚本，用于启动 Saleor 并通过 GraphQL 下单。让我分析现有脚本并创建新脚本。

[3 tools called]

现在让我设置脚本的可执行权限：

[2 tools called]

✅ 我已经成功创建了 `s1_start_saleor_and_place_order_by_graphql.sh` 脚本，该脚本实现了以下功能：

## 🎯 主要特性

### 📋 完整的 GraphQL 自动化流程
1. **第一步：Add Webhook**
   - 获取用户认证Token
   - 创建App并获取App Token
   - 创建Webhook（包含ORDER_CREATED事件）

2. **第二步：Create an Order**
   - 获取产品Variant ID
   - 创建完整的Checkout
   - 设置配送方式
   - 创建订单并触发Webhook

3. **第三步：Mark Order as Paid**
   - 标记订单为已支付
   - 验证支付状态

### 🔍 详细的日志输出
- **GraphQL请求日志**：每个GraphQL操作都有详细的请求和响应日志
- **调试信息**：包含Token、ID等关键信息的前缀显示
- **颜色编码**：使用不同颜色区分不同类型的消息
- **步骤跟踪**：清晰标记每个步骤的进度

### 🛠️ 技术实现
- 基于参考脚本的成熟架构
- 使用已验证的GraphQL执行函数
- 包含错误处理和服务等待机制
- 自动启动Saleor服务
- 内置webhook连接测试

### 🌐 预配置参数
- **Webhook URL**: `https://webhook.site/99475069-12a9-4a24-8952-b3246f7ca573`
- **测试邮箱**: `webhook-test@example.com`
- **管理员登录**: `admin@example.com / admin`

## 🚀 使用方法

```bash
./s1_start_saleor_and_place_order_by_graphql.sh
```

脚本会自动：
1. 启动Saleor服务（如果存在`s1_start_saleor.sh`）
2. 等待服务启动完成
3. 执行完整的GraphQL自动化下单流程
4. 在每一步都输出详细的日志信息
5. 最终提供完整的操作总结

## 📊 日志特性
- 🔗 **GraphQL请求日志**：显示正在执行的操作
- 📦 **响应日志**：显示响应长度和内容摘要
- 🔍 **调试信息**：Token、ID等关键信息
- ✅ **成功标记**：每个步骤的成功确认
- ⚠️ **警告信息**：潜在问题提示

这个脚本完全基于你提供的手工操作步骤，将所有GraphQL查询和操作自动化，并添加了丰富的日志输出以便跟踪和调试。
```
