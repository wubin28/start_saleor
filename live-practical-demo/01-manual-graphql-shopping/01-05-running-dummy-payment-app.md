# Running Dummy Payment App

```markdown
看到你遇到的支付网关配置问题了。确实，Saleor在本地开发环境中的支付配置是一个常见挑战。让我为你提供几种解决方案：根据你遇到的问题，我为你提供几种解决方案。你的情况是典型的本地开发环境支付网关配置问题，好消息是Saleor官方提供了专门的解决方案。

## 解决方案：使用官方Dummy Payment App（推荐；实际采纳）

Saleor官方提供了一个专门的Dummy Payment App，允许你在不需要真实支付提供商的情况下测试Saleor的支付和结账功能。你可以创建订单、处理支付、发起退款等，所有这些都在Saleor Dashboard中进行。

### 安装步骤：

1. **克隆官方Dummy Payment App**：
```bash
git clone https://github.com/saleor/dummy-payment-app.git
cd dummy-payment-app
```

2. **安装依赖**：
```bash
npm install --global corepack@latest
corepack enable pnpm
pnpm install
```

3. **启动应用**：
```bash
pnpm run dev --port 3001
```
应用将在 http://localhost:3001 运行。

4. **使用ngrok暴露本地应用**：
```bash
# 安装ngrok
brew install ngrok

# Run the following command to add your authtoken to the default ngrok.yml configuration file.
ngrok config add-authtoken 30ufJJclmispe35KnzJ281tUY7P_3UXmDQrcYXny3uZwv96D1
# Authtoken saved to configuration file: /Users/binwu/Library/Application Support/ngrok/ngrok.yml


# Deploy your app online
# Put your app online at an ephemeral domain forwarding to your upstream service. For example, if it is listening on port http://localhost:3001, run:
ngrok http http://localhost:3001
```

5. **安装Dummy Payment App**：

# 使用GraphQL Playground (通常在 http://localhost:8000/graphql/)
# 或者使用任何GraphQL客户端

### 获取用户认证Token
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


mutation InstallApp {
  appInstall(
    input: {
      appName: "Dummy Payment App"
      manifestUrl: "https://2a0f82c20f05.ngrok-free.app/api/manifest"
      permissions: [HANDLE_PAYMENTS, HANDLE_CHECKOUTS]
    }
  ) {
    appInstallation {
      id
      status
      appName
      manifestUrl
    }
    appErrors {
      field
      message
      code
    }
  }
}

GraphiQL输出结果:
{
  "data": {
    "appInstall": {
      "appInstallation": {
        "id": "QXBwSW5zdGFsbGF0aW9uOjE=",
        "status": "PENDING",
        "appName": "Dummy Payment App",
        "manifestUrl": "https://2a0f82c20f05.ngrok-free.app/api/manifest"
      },
      "appErrors": []
    }
  },
  "extensions": {
    "cost": {
      "requestedQueryCost": 0,
      "maximumAvailable": 50000
    }
  }
}



# 查看安装状态
query CheckInstallations {
  appsInstallations {
    id
    status
    appName
    manifestUrl
    createdAt
  }
}

GraphiQL输出：
{
  "data": {
    "appsInstallations": []
  },
  "extensions": {
    "cost": {
      "requestedQueryCost": 1,
      "maximumAvailable": 50000
    }
  }
}

# 查看已安装的应用
query ListApps {
  apps(first: 10) {
    edges {
      node {
        id
        name
        isActive
        permissions {
          name
          code
        }
      }
    }
  }
}

GraphiQL输出：
{
  "data": {
    "apps": {
      "edges": [
        {
          "node": {
            "id": "QXBwOjQ=",
            "name": "Dummy Payment App",
            "isActive": true,
            "permissions": [
              {
                "name": "Handle checkouts",
                "code": "HANDLE_CHECKOUTS"
              },
              {
                "name": "Handle payments",
                "code": "HANDLE_PAYMENTS"
              }
            ]
          }
        },
        {
          "node": {
            "id": "QXBwOjI=",
            "name": "My App",
            "isActive": true,
            "permissions": [
              {
                "name": "Handle checkouts",
                "code": "HANDLE_CHECKOUTS"
              },
              {
                "name": "Manage orders.",
                "code": "MANAGE_ORDERS"
              }
            ]
          }
        },
        {
          "node": {
            "id": "QXBwOjM=",
            "name": "My App with payload configured using subscription",
            "isActive": true,
            "permissions": [
              {
                "name": "Handle checkouts",
                "code": "HANDLE_CHECKOUTS"
              },
              {
                "name": "Manage orders.",
                "code": "MANAGE_ORDERS"
              }
            ]
          }
        }
      ]
    }
  },
  "extensions": {
    "cost": {
      "requestedQueryCost": 10,
      "maximumAvailable": 50000
    }
  }
}


### 使用方法：

安装后，你可以通过应用的Dashboard创建Checkout，设置配送方式，然后使用transactionInitialize mutation初始化交易。应用的响应可以通过提供的输入进行修改。
```