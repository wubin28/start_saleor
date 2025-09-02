# Place Order by GraphQL API

Me:
```markdown
请阅读 @[s1_to_s4_start_and_reinstall_dummy_payment_app.sh] ，然后在 main()函数最后的“return 0”之前，将以下手工操作转为脚本并添加进去，要求每执行一个graphql，都要在终端输出日志，以便跟踪和调试。下面是手工操作：【## 🔧 第一步：Add Webhook

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
