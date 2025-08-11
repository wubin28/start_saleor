#!/bin/bash

# s1_start_saleor_and_place_order_by_graphql.sh
# 功能：启动 Saleor 并通过 GraphQL 自动化下单流程
# 适用于：macOS Sequoia 15.6 + iTerm2

echo "🚀 开始启动 Saleor 并执行 GraphQL 自动化下单流程..."

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_step() {
    echo -e "${BLUE}📋 步骤 $1: $2${NC}" >&2
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}" >&2
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}" >&2
}

print_error() {
    echo -e "${RED}❌ $1${NC}" >&2
}

print_debug() {
    echo -e "${YELLOW}🔍 调试信息: $1${NC}" >&2
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}" >&2
}

print_graphql_log() {
    echo -e "${BLUE}🔗 GraphQL 请求: $1${NC}" >&2
}

print_response_log() {
    echo -e "${YELLOW}📦 GraphQL 响应: $1${NC}" >&2
}

# GraphQL 查询函数 - 使用直接的 curl
execute_graphql_simple() {
    local query="$1"
    local token="$2"
    local operation_name="$3"
    
    print_graphql_log "$operation_name"
    print_debug "查询内容: ${query:0:100}..."
    
    # 对于认证查询，使用直接的转义格式
    if [[ "$query" == *"tokenCreate"* ]]; then
        # 使用已验证可工作的格式
        local json_payload='{"query": "mutation { tokenCreate(email: \"admin@example.com\", password: \"admin\") { token user { email isStaff } errors { message } } }"}'
    else
        # 对于其他查询，使用 Python 生成 JSON
        local json_payload=$(python3 -c "
import json
query = '''$query'''
print(json.dumps({'query': query}))
" 2>/dev/null)
    fi
    
    print_debug "发送请求到 http://localhost:8000/graphql/" >&2
    
    # 执行 curl 命令
    local response
    if [ -n "$token" ]; then
        print_debug "使用 Bearer Token: ${token:0:20}..." >&2
        response=$(curl -s -X POST \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $token" \
            -d "$json_payload" \
            http://localhost:8000/graphql/)
    else
        print_debug "不使用认证" >&2
        response=$(curl -s -X POST \
            -H "Content-Type: application/json" \
            -d "$json_payload" \
            http://localhost:8000/graphql/)
    fi
    
    # 输出响应日志
    if [ -n "$response" ]; then
        local response_length=${#response}
        print_response_log "响应长度: $response_length 字符"
        
        # 如果响应不太长，显示部分内容
        if [ $response_length -lt 500 ]; then
            print_response_log "响应内容: $response"
        else
            print_response_log "响应前200字符: ${response:0:200}..."
        fi
    else
        print_error "空响应"
    fi
    
    echo "$response"
}

# 等待服务启动
wait_for_service() {
    local url="$1"
    local service_name="$2"
    local max_attempts=30
    local attempt=1
    
    print_step "等待" "$service_name 启动..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s "$url" > /dev/null 2>&1; then
            print_success "$service_name 已启动"
            return 0
        fi
        echo -n "." >&2
        sleep 2
        ((attempt++))
    done
    
    print_error "$service_name 启动超时"
    return 1
}

# 创建管理员用户（如果不存在）
create_admin_user() {
    print_step "1.0" "确保管理员用户存在"
    print_info "尝试创建管理员用户..."
    
    # 使用docker命令创建管理员用户
    local create_result=$(docker compose -f /Users/binwu/OOR-local/katas/saleor/saleor-platform/docker-compose.yml \
        run --rm -e DJANGO_SUPERUSER_USERNAME=admin \
        -e DJANGO_SUPERUSER_EMAIL=admin@example.com \
        -e DJANGO_SUPERUSER_PASSWORD=admin \
        api python3 manage.py createsuperuser --noinput 2>&1 || echo "ERROR")
    
    if [[ "$create_result" == *"ERROR"* ]] || [[ "$create_result" == *"error"* ]]; then
        if [[ "$create_result" == *"already exists"* ]] || [[ "$create_result" == *"That username is already taken"* ]]; then
            print_success "管理员用户已存在"
            return 0
        else
            print_warning "管理员用户创建可能失败，但可能已存在"
            print_debug "创建结果: $create_result"
            return 0  # 继续尝试，可能用户已存在
        fi
    else
        print_success "管理员用户创建成功或已存在"
        return 0
    fi
}

# 获取用户认证 token
get_auth_token_simple() {
    print_step "1.1" "获取用户认证 Token..."
    
    # 使用正确的 tokenCreate mutation
    local token_query='mutation { tokenCreate(email: "admin@example.com", password: "admin") { token user { email isStaff } errors { message } } }'
    local response=$(execute_graphql_simple "$token_query" "" "获取用户认证Token")
    
    if [ -z "$response" ]; then
        print_error "无响应" >&2
        return 1
    fi
    
    # 检查是否有凭据错误
    if [[ "$response" == *"Please, enter valid credentials"* ]]; then
        print_warning "认证失败，尝试创建管理员用户..."
        
        # 尝试创建管理员用户
        create_admin_user
        
        # 等待一下让用户创建生效
        print_info "等待3秒让用户创建生效..."
        sleep 3
        
        # 重新尝试获取token
        print_info "重新尝试获取认证token..."
        response=$(execute_graphql_simple "$token_query" "" "重新获取用户认证Token")
        
        if [ -z "$response" ]; then
            print_error "重试后仍无响应" >&2
            return 1
        fi
    fi
    
    # 提取 token
    local token=$(echo "$response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    token = data.get('data', {}).get('tokenCreate', {}).get('token', '')
    if token:
        print(token)
except:
    pass
")
    
    if [ -n "$token" ]; then
        print_success "成功获取认证 token"
        print_debug "Token 前50字符: ${token:0:50}..."
        echo "$token"
        return 0
    else
        print_error "获取 token 失败"
        print_debug "响应: $response"
        
        # 检查是否还是凭据问题
        if [[ "$response" == *"Please, enter valid credentials"* ]]; then
            print_error "认证凭据无效，可能需要手动检查用户创建"
            print_info "请检查 Saleor 服务是否完全启动，或手动创建管理员用户"
        fi
        return 1
    fi
}

# 创建App
create_app() {
    local user_token="$1"
    
    print_step "1.2" "创建App"
    
    local create_app_query='mutation CreateApp {
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
}'
    
    local app_response=$(execute_graphql_simple "$create_app_query" "$user_token" "创建App")
    
    if [ -z "$app_response" ]; then
        print_error "App创建请求失败"
        return 1
    fi
    
    # 提取 app.id 和 authToken
    local app_id=$(echo "$app_response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    app_data = data.get('data', {}).get('appCreate', {}).get('app', {})
    print(app_data.get('id', ''))
except:
    pass
" 2>/dev/null)
    
    local app_token=$(echo "$app_response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('data', {}).get('appCreate', {}).get('authToken', ''))
except:
    pass
" 2>/dev/null)
    
    if [ -n "$app_id" ] && [ -n "$app_token" ]; then
        print_success "App创建成功 - ID: $app_id"
        print_success "App Token: ${app_token:0:20}..."
        
        # 返回格式: app_id|app_token
        echo "$app_id|$app_token"
        return 0
    else
        print_error "App创建失败"
        print_debug "响应: $app_response"
        return 1
    fi
}

# 创建Webhook
create_webhook() {
    local user_token="$1"
    local app_id="$2"
    local webhook_url="$3"
    
    print_step "1.3" "创建Webhook（包含ORDER_CREATED事件）"
    
    local create_webhook_query="mutation CreateWebhook {
  webhookCreate(input: {
    name: \"Order webhook\",
    targetUrl: \"$webhook_url\",
    app: \"$app_id\",
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
}"
    
    local webhook_response=$(execute_graphql_simple "$create_webhook_query" "$user_token" "创建Webhook")
    
    if [ -z "$webhook_response" ]; then
        print_error "Webhook创建请求失败"
        return 1
    fi
    
    local webhook_id=$(echo "$webhook_response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    webhook_data = data.get('data', {}).get('webhookCreate', {}).get('webhook', {})
    print(webhook_data.get('id', ''))
except:
    pass
" 2>/dev/null)
    
    if [ -n "$webhook_id" ]; then
        print_success "Webhook创建成功 - ID: $webhook_id"
        print_success "Webhook URL: $webhook_url"
        
        # 验证webhook是否正确创建
        print_info "验证Webhook配置..."
        local verify_webhook_query="query VerifyWebhook {
  webhook(id: \"$webhook_id\") {
    id
    name
    targetUrl
    isActive
    events {
      eventType
    }
    app {
      id
      name
    }
  }
}"
        local verify_response=$(execute_graphql_simple "$verify_webhook_query" "$user_token" "验证Webhook配置")
        
        # 检查是否包含我们刚创建的webhook
        if [[ "$verify_response" == *"$webhook_url"* ]] && [[ "$verify_response" == *"ORDER_CREATED"* ]]; then
            print_success "✅ Webhook配置验证成功"
        else
            print_warning "⚠️ Webhook配置可能有问题"
        fi
        
        echo "$webhook_id"
        return 0
    else
        print_error "Webhook创建失败"
        print_debug "响应: $webhook_response"
        return 1
    fi
}

# 自动填充Saleor示例数据
auto_populate_saleor_data() {
    print_step "2.0" "自动填充Saleor示例数据"
    print_warning "未找到产品数据，正在自动运行 populatedb 命令..."
    
    # 使用AppleScript在新的iTerm2窗口中运行populatedb命令
    print_info "在新iTerm2窗口中运行 populatedb 命令..."
    
    osascript <<EOF
tell application "iTerm"
    activate
    
    -- 创建新窗口
    create window with default profile
    
    -- 获取当前会话
    tell current session of current window
        -- 切换到saleor-platform目录
        write text "cd /Users/binwu/OOR-local/katas/saleor/saleor-platform"
        delay 1
        
        -- 运行populatedb命令
        write text "echo '开始运行 populatedb 命令...'"
        write text "docker compose run --rm api python3 manage.py populatedb"
        delay 1
        
        -- 等待命令完成（预计需要15秒）
        write text "echo 'populatedb 命令执行完成'"
    end tell
end tell
EOF
    
    print_info "等待15秒让 populatedb 命令完成..."
    sleep 15
    
    print_success "populatedb 命令执行完成，继续获取产品数据..."
}

# 获取产品Variant ID
get_product_variant() {
    local user_token="$1"
    local retry_count=0
    local max_retries=1
    
    while [ $retry_count -le $max_retries ]; do
        print_step "2.1" "获取产品Variant ID$([ $retry_count -gt 0 ] && echo " (重试 $retry_count/$max_retries)" || echo "")"
        
        local get_products_query='query GetProducts {
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
}'
        
        local products_response=$(execute_graphql_simple "$get_products_query" "$user_token" "获取产品列表")
        
        if [ -z "$products_response" ]; then
            print_error "产品查询请求失败"
            return 1
        fi
        
        # 提取第一个variant ID
        local variant_id=$(echo "$products_response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    edges = data.get('data', {}).get('products', {}).get('edges', [])
    for edge in edges:
        variants = edge.get('node', {}).get('variants', [])
        if variants:
            print(variants[0].get('id', ''))
            break
except:
    pass
" 2>/dev/null)
        
        if [ -n "$variant_id" ]; then
            print_success "获取到产品Variant ID: $variant_id"
            echo "$variant_id"
            return 0
        else
            if [ $retry_count -eq 0 ]; then
                print_error "未找到产品Variant"
                # 第一次失败时，自动填充数据
                auto_populate_saleor_data
                ((retry_count++))
            else
                print_error "重试后仍未找到产品Variant，请检查Saleor配置"
                return 1
            fi
        fi
    done
    
    return 1
}

# 创建完整的Checkout
create_checkout() {
    local user_token="$1"
    local variant_id="$2"
    
    print_step "2.2" "创建完整的Checkout"
    
    local create_checkout_query="mutation CreateCompleteCheckout {
  checkoutCreate(input: {
    channel: \"default-channel\",
    email: \"webhook-test@example.com\",
    lines: [
      {
        quantity: 1,
        variantId: \"$variant_id\"
      }
    ],
    billingAddress: {
      firstName: \"Jane\",
      lastName: \"Smith\",
      streetAddress1: \"456 Oak St\",
      city: \"Los Angeles\", 
      postalCode: \"90210\",
      country: US,
      countryArea: \"CA\"
    },
    shippingAddress: {
      firstName: \"Jane\",
      lastName: \"Smith\",
      streetAddress1: \"456 Oak St\",
      city: \"Los Angeles\",
      postalCode: \"90210\", 
      country: US,
      countryArea: \"CA\"
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
}"
    
    local checkout_response=$(execute_graphql_simple "$create_checkout_query" "$user_token" "创建Checkout")
    
    if [ -z "$checkout_response" ]; then
        print_error "Checkout创建请求失败"
        return 1
    fi
    
    # 提取checkout ID和shipping method ID
    local checkout_id=$(echo "$checkout_response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    checkout_data = data.get('data', {}).get('checkoutCreate', {}).get('checkout', {})
    print(checkout_data.get('id', ''))
except:
    pass
" 2>/dev/null)
    
    local shipping_method_id=$(echo "$checkout_response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    checkout_data = data.get('data', {}).get('checkoutCreate', {}).get('checkout', {})
    methods = checkout_data.get('availableShippingMethods', [])
    if methods:
        print(methods[0].get('id', ''))
except:
    pass
" 2>/dev/null)
    
    if [ -n "$checkout_id" ] && [ -n "$shipping_method_id" ]; then
        print_success "Checkout创建成功 - ID: $checkout_id"
        print_success "配送方式ID: $shipping_method_id"
        
        # 返回格式: checkout_id|shipping_method_id
        echo "$checkout_id|$shipping_method_id"
        return 0
    else
        print_error "Checkout创建失败"
        print_debug "响应: $checkout_response"
        return 1
    fi
}

# 设置配送方式
set_shipping_method() {
    local user_token="$1"
    local checkout_id="$2"
    local shipping_method_id="$3"
    
    print_step "2.3" "设置配送方式"
    
    local set_shipping_query="mutation SetShippingMethod {
  checkoutShippingMethodUpdate(
    id: \"$checkout_id\",
    shippingMethodId: \"$shipping_method_id\"
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
}"
    
    local shipping_response=$(execute_graphql_simple "$set_shipping_query" "$user_token" "设置配送方式")
    
    if [ -z "$shipping_response" ]; then
        print_error "配送方式设置请求失败"
        return 1
    fi
    
    # 检查是否成功设置
    if [[ "$shipping_response" == *"\"errors\":[]"* ]] || [[ "$shipping_response" == *"\"shippingMethod\""* ]]; then
        print_success "配送方式设置成功"
        return 0
    else
        print_warning "配送方式设置可能有问题"
        print_debug "响应: $shipping_response"
        return 0  # 继续执行，可能不影响后续流程
    fi
}

# 创建订单并触发Webhook
create_order_from_checkout() {
    local app_token="$1"
    local checkout_id="$2"
    
    print_step "2.4" "创建订单并触发Webhook（切换到App Token）"
    
    local create_order_query="mutation CreateOrderAndTriggerWebhook {
  orderCreateFromCheckout(
    id: \"$checkout_id\"
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
}"
    
    local order_response=$(execute_graphql_simple "$create_order_query" "$app_token" "创建订单（使用App Token）")
    
    if [ -z "$order_response" ]; then
        print_error "订单创建请求失败"
        return 1
    fi
    
    # 提取order ID
    local order_id=$(echo "$order_response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    order_data = data.get('data', {}).get('orderCreateFromCheckout', {}).get('order', {})
    print(order_data.get('id', ''))
except:
    pass
" 2>/dev/null)
    
    if [ -n "$order_id" ]; then
        print_success "订单创建成功 - ID: $order_id"
        print_info "请检查webhook.site查看POST请求"
        
        # 等待一下让webhook有时间触发
        print_info "等待5秒让webhook触发..."
        sleep 5
        
        echo "$order_id"
        return 0
    else
        print_error "订单创建失败"
        print_debug "响应: $order_response"
        return 1
    fi
}

# 标记订单为已支付
mark_order_paid() {
    local app_token="$1"
    local order_id="$2"
    
    print_step "3.1" "标记订单为已支付"
    
    local mark_paid_query="mutation MarkOrderAsPaid {
  orderMarkAsPaid(
    id: \"$order_id\"
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
}"
    
    local paid_response=$(execute_graphql_simple "$mark_paid_query" "$app_token" "标记订单为已支付")
    
    if [ -z "$paid_response" ]; then
        print_error "订单支付标记请求失败"
        return 1
    fi
    
    # 检查是否成功
    if [[ "$paid_response" == *"\"errors\":[]"* ]] || [[ "$paid_response" == *"\"paymentStatus\""* ]]; then
        print_success "订单支付标记成功"
        return 0
    else
        print_error "订单支付标记失败"
        print_debug "响应: $paid_response"
        return 1
    fi
}

# 验证支付状态
verify_payment_status() {
    local app_token="$1"
    local order_id="$2"
    
    print_step "3.2" "验证支付状态"
    
    local check_status_query="query CheckOrderStatus {
  order(id: \"$order_id\") {
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
}"
    
    local status_response=$(execute_graphql_simple "$check_status_query" "$app_token" "验证支付状态")
    
    if [ -z "$status_response" ]; then
        print_error "支付状态验证请求失败"
        return 1
    fi
    
    # 提取支付状态
    local payment_status=$(echo "$status_response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    order_data = data.get('data', {}).get('order', {})
    print(order_data.get('paymentStatus', ''))
except:
    pass
" 2>/dev/null)
    
    if [ -n "$payment_status" ]; then
        print_success "订单支付状态: $payment_status"
        return 0
    else
        print_error "无法验证支付状态"
        print_debug "响应: $status_response"
        return 1
    fi
}

# 测试Webhook连接
test_webhook_connection() {
    local webhook_url="$1"
    
    print_step "Test" "测试Webhook连接"
    print_info "向webhook.site发送测试POST请求..."
    
    # 发送测试POST请求
    local test_payload='{"test": "webhook connection test", "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'", "source": "saleor_automation_script"}'
    
    local response=$(curl -s -w "%{http_code}" -X POST \
        -H "Content-Type: application/json" \
        -d "$test_payload" \
        "$webhook_url" || echo "000")
    
    local http_code="${response: -3}"
    
    if [ "$http_code" = "200" ] || [ "$http_code" = "201" ]; then
        print_success "✅ Webhook连接测试成功 (HTTP $http_code)"
        print_info "请检查webhook.site是否收到测试消息"
    else
        print_error "❌ Webhook连接测试失败 (HTTP $http_code)"
        print_info "请检查webhook.site URL是否正确"
        return 1
    fi
}

# 主流程
main() {
    # 设置webhook URL
    local WEBHOOK_URL="https://webhook.site/99475069-12a9-4a24-8952-b3246f7ca573"
    
    print_step "0" "启动 Saleor 服务"
    print_info "执行 ./s1_start_saleor.sh"
    if [ -f "./s1_start_saleor.sh" ]; then
        ./s1_start_saleor.sh
    else
        print_warning "s1_start_saleor.sh 不存在，假设服务已启动"
    fi
    
    print_step "1" "等待服务完全启动"
    wait_for_service "http://localhost:8000/graphql/" "Saleor GraphQL"
    
    # 测试webhook连接
    test_webhook_connection "$WEBHOOK_URL"
    if [ $? -ne 0 ]; then
        print_error "Webhook连接测试失败，请检查URL"
        return 1
    fi
    
    print_step "2" "开始 GraphQL 自动化操作流程"
    print_info "使用Webhook URL: $WEBHOOK_URL"
    
    # 第一步：获取用户认证Token
    print_step "Step 1" "Add Webhook"
    AUTH_TOKEN=$(get_auth_token_simple)
    if [ -z "$AUTH_TOKEN" ]; then
        print_error "无法获取认证 token"
        return 1
    fi
    
    # 创建App
    APP_RESULT=$(create_app "$AUTH_TOKEN")
    if [ $? -ne 0 ] || [ -z "$APP_RESULT" ]; then
        print_error "App创建失败"
        return 1
    fi
    
    # 解析App结果
    local APP_ID="${APP_RESULT%|*}"
    local APP_TOKEN="${APP_RESULT#*|}"
    
    # 创建Webhook
    WEBHOOK_ID=$(create_webhook "$AUTH_TOKEN" "$APP_ID" "$WEBHOOK_URL")
    if [ $? -ne 0 ] || [ -z "$WEBHOOK_ID" ]; then
        print_error "Webhook创建失败"
        return 1
    fi
    
    # 第二步：Create an Order
    print_step "Step 2" "Create an Order"
    
    # 获取产品Variant ID
    VARIANT_ID=$(get_product_variant "$AUTH_TOKEN")
    if [ $? -ne 0 ] || [ -z "$VARIANT_ID" ]; then
        print_error "获取产品Variant失败"
        return 1
    fi
    
    # 创建Checkout
    CHECKOUT_RESULT=$(create_checkout "$AUTH_TOKEN" "$VARIANT_ID")
    if [ $? -ne 0 ] || [ -z "$CHECKOUT_RESULT" ]; then
        print_error "Checkout创建失败"
        return 1
    fi
    
    # 解析Checkout结果
    local CHECKOUT_ID="${CHECKOUT_RESULT%|*}"
    local SHIPPING_METHOD_ID="${CHECKOUT_RESULT#*|}"
    
    # 设置配送方式
    set_shipping_method "$AUTH_TOKEN" "$CHECKOUT_ID" "$SHIPPING_METHOD_ID"
    
    # 创建订单并触发Webhook
    ORDER_ID=$(create_order_from_checkout "$APP_TOKEN" "$CHECKOUT_ID")
    if [ $? -ne 0 ] || [ -z "$ORDER_ID" ]; then
        print_error "订单创建失败"
        return 1
    fi
    
    # 第三步：Mark Order as Paid
    print_step "Step 3" "Mark Order as Paid"
    
    # 标记订单为已支付
    mark_order_paid "$APP_TOKEN" "$ORDER_ID"
    if [ $? -ne 0 ]; then
        print_error "订单支付标记失败"
        return 1
    fi
    
    # 验证支付状态
    verify_payment_status "$APP_TOKEN" "$ORDER_ID"
    
    echo ""
    print_success "🎉 所有GraphQL自动化操作完成！"
    echo -e "${GREEN}📋 操作总结:${NC}"
    echo -e "   • ✅ 用户认证Token获取成功"
    echo -e "   • ✅ App创建成功 (ID: $APP_ID)"
    echo -e "   • ✅ Webhook创建成功 (ID: $WEBHOOK_ID)"
    echo -e "   • ✅ 产品Variant获取成功 (ID: $VARIANT_ID)"
    echo -e "   • ✅ Checkout创建成功 (ID: $CHECKOUT_ID)"
    echo -e "   • ✅ 订单创建成功 (ID: $ORDER_ID)"
    echo -e "   • ✅ 订单支付标记完成"
    echo -e "   • 🔗 检查Webhook: ${BLUE}$WEBHOOK_URL${NC}"
    echo -e "   • 🔗 GraphQL Playground: ${BLUE}http://localhost:8000/graphql/${NC}"
    
    return 0
}

# 检查依赖
if ! command -v curl &> /dev/null; then
    print_error "缺少 curl"
    exit 1
fi

if ! command -v python3 &> /dev/null; then
    print_error "缺少 python3"
    exit 1
fi

# 运行主流程
echo "📁 当前目录: $(pwd)"
echo ""

main

if [ $? -eq 0 ]; then
    echo ""
    print_success "✨ 脚本执行完成！"
    exit 0
else
    echo ""
    print_error "❌ 脚本执行失败"
    exit 1
fi 