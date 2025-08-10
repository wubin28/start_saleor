#!/bin/bash

# reinstall_dummy_payment_app.sh
# 功能：自动重新安装 Dummy Payment App
# 适用于：macOS Sequoia 15.6 + iTerm2

set -e  # 遇到错误时退出

echo "🚀 开始自动重新安装 Dummy Payment App..."

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_step() {
    echo -e "${BLUE}📋 步骤 $1: $2${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_debug() {
    echo -e "${YELLOW}🔍 调试信息: $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# GraphQL 查询函数
execute_graphql() {
    local query="$1"
    local token="$2"
    local headers=""
    
    print_debug "execute_graphql: 开始执行 GraphQL 查询"
    print_debug "execute_graphql: 查询长度: ${#query}"
    
    if [ -n "$token" ]; then
        headers="-H \"Authorization: Bearer $token\""
        print_debug "execute_graphql: 使用认证 token"
    else
        print_debug "execute_graphql: 无认证 token"
    fi
    
    print_debug "execute_graphql: 发送请求到 http://localhost:8000/graphql/"
    local curl_result
    curl_result=$(curl -s -X POST \
        --connect-timeout 10 \
        --max-time 30 \
        -H "Content-Type: application/json" \
        $headers \
        -d "{\"query\": \"$query\"}" \
        http://localhost:8000/graphql/ 2>&1)
    local curl_exit_code=$?
    print_debug "execute_graphql: curl 命令执行完成，退出码: $curl_exit_code"
    
    if [ $curl_exit_code -ne 0 ]; then
        print_debug "execute_graphql: curl 错误输出: $curl_result"
        echo ""  # 返回空字符串表示失败
    else
        echo "$curl_result"
    fi
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
        echo -n "."
        sleep 2
        ((attempt++))
    done
    
    print_error "$service_name 启动超时"
    return 1
}

# 获取 ngrok URL
get_ngrok_url() {
    local max_attempts=30
    local attempt=1
    
    print_step "获取" "ngrok forwarding URL..."
    
    while [ $attempt -le $max_attempts ]; do
        # 尝试从 ngrok API 获取 URL
        local ngrok_response=$(curl -s http://localhost:4040/api/tunnels 2>/dev/null || echo "")
        
        if [ -n "$ngrok_response" ]; then
            # 提取指向 localhost:3001 的 HTTPS URL
            local ngrok_url=$(echo "$ngrok_response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for tunnel in data.get('tunnels', []):
        if tunnel.get('config', {}).get('addr') == 'http://localhost:3001' and tunnel.get('proto') == 'https':
            print(tunnel.get('public_url', ''))
            break
except:
    pass
" 2>/dev/null)
            
            if [ -n "$ngrok_url" ]; then
                print_success "获取到 ngrok URL: $ngrok_url"
                print_debug "从 ngrok API 提取的完整 forwarding URL: $ngrok_url"
                print_info "对应的 manifest URL 将是: ${ngrok_url}/api/manifest"
                # 等待 ngrok URL 完全可用
                print_step "等待" "ngrok URL 完全可用..."
                sleep 10
                echo "$ngrok_url"
                return 0
            fi
        fi
        
        echo -n "."
        sleep 2
        ((attempt++))
    done
    
    print_error "无法获取 ngrok URL"
    return 1
}

# 验证 manifest 端点
verify_manifest() {
    local ngrok_url="$1"
    local manifest_url="${ngrok_url}/api/manifest"
    
    print_step "验证" "manifest 端点: $manifest_url"
    
    # 尝试多次访问，因为 ngrok 可能需要一些时间来完全准备就绪
    local max_attempts=5
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        local response=$(curl -s -o /dev/null -w "%{http_code}" "$manifest_url" --connect-timeout 10 --max-time 30)
        
        if [ "$response" = "200" ]; then
            print_success "manifest 端点可访问"
            return 0
        elif [ "$response" = "000" ]; then
            print_warning "连接超时，重试中... (尝试 $attempt/$max_attempts)"
        else
            print_warning "HTTP $response，重试中... (尝试 $attempt/$max_attempts)"
        fi
        
        sleep 5
        ((attempt++))
    done
    
    print_error "manifest 端点不可访问，最后状态码: $response"
    print_warning "请手动检查 URL 是否可访问: $manifest_url"
    return 1
}

# 获取用户认证 token
get_auth_token() {
    print_step "获取" "用户认证 token..."
    print_debug "准备执行 tokenCreate GraphQL 查询..."
    
    local query='mutation GetUserToken { tokenCreate(email: \"admin@example.com\", password: \"admin\") { token user { email isStaff } errors { message } } }'
    
    print_debug "开始调用 execute_graphql 获取认证 token..."
    local response=$(execute_graphql "$query")
    local execute_exit_code=$?
    print_debug "execute_graphql 调用完成，退出码: $execute_exit_code，响应长度: ${#response}"
    
    if [ $execute_exit_code -ne 0 ]; then
        print_error "execute_graphql 调用失败，退出码: $execute_exit_code"
        return 1
    fi
    
    if [ -z "$response" ]; then
        print_error "GraphQL 响应为空，可能是网络连接问题"
        return 1
    fi
    
    print_debug "开始解析 JSON 响应获取 token..."
    # 提取 token
    local token=$(echo "$response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    token_data = data.get('data', {}).get('tokenCreate', {})
    if token_data.get('errors'):
        print('ERROR: ' + str(token_data['errors']))
    else:
        print(token_data.get('token', ''))
except Exception as e:
    print('ERROR: ' + str(e))
" 2>/dev/null)
    
    if [[ "$token" == ERROR:* ]]; then
        print_error "获取 token 失败: ${token#ERROR: }"
        return 1
    elif [ -n "$token" ]; then
        print_success "成功获取认证 token"
        echo "$token"
        return 0
    else
        print_error "获取 token 失败"
        return 1
    fi
}

# 获取 Dummy Payment App ID
get_dummy_app_id() {
    local token="$1"
    
    print_step "查找" "Dummy Payment App ID..."
    print_debug "准备执行 GraphQL 查询获取应用列表..."
    
    local query='query ListApps { apps(first: 10) { edges { node { id name isActive } } } }'
    
    print_debug "开始调用 execute_graphql 函数..."
    local response=$(execute_graphql "$query" "$token")
    print_debug "execute_graphql 函数调用完成，响应长度: ${#response}"
    
    # 提取 Dummy Payment App 的 ID
    local app_id=$(echo "$response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    apps = data.get('data', {}).get('apps', {}).get('edges', [])
    for app in apps:
        node = app.get('node', {})
        if node.get('name') == 'Dummy Payment App':
            print(node.get('id', ''))
            break
except:
    pass
" 2>/dev/null)
    
    if [ -n "$app_id" ]; then
        print_success "找到 Dummy Payment App ID: $app_id"
        print_debug "将要卸载的 Dummy Payment App ID: $app_id"
        echo "$app_id"
        return 0
    else
        print_warning "未找到 Dummy Payment App（可能已卸载）"
        print_debug "在应用列表中未找到名为 'Dummy Payment App' 的应用"
        return 1
    fi
}

# 卸载应用
uninstall_app() {
    local token="$1"
    local app_id="$2"
    
    print_step "卸载" "Dummy Payment App (ID: $app_id)..."
    
    local query="mutation DeleteApp { appDelete(id: \\\"$app_id\\\") { app { id name } appErrors { field message code } } }"
    
    local response=$(execute_graphql "$query" "$token")
    
    # 检查是否有错误
    local errors=$(echo "$response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    app_errors = data.get('data', {}).get('appDelete', {}).get('appErrors', [])
    if app_errors:
        for error in app_errors:
            print(f\"ERROR: {error.get('message', 'Unknown error')}\")
    else:
        app_data = data.get('data', {}).get('appDelete', {}).get('app', {})
        if app_data:
            print(f\"SUCCESS: Uninstalled {app_data.get('name', 'Unknown app')}\")
        else:
            print('ERROR: No app data returned')
except Exception as e:
    print(f'ERROR: {str(e)}')
" 2>/dev/null)
    
    if [[ "$errors" == SUCCESS:* ]]; then
        print_success "成功卸载应用: ${errors#SUCCESS: }"
        print_debug "已卸载的应用 ID: $app_id"
        return 0
    else
        print_error "卸载失败: ${errors#ERROR: }"
        return 1
    fi
}

# 安装应用
install_app() {
    local token="$1"
    local ngrok_url="$2"
    local manifest_url="${ngrok_url}/api/manifest"
    
    print_step "安装" "Dummy Payment App (manifest: $manifest_url)..."
    print_debug "使用的 manifestUrl: $manifest_url"
    print_info "安装参数: appName='Dummy Payment App', permissions=[HANDLE_PAYMENTS, HANDLE_CHECKOUTS]"
    
    local query="mutation InstallApp { appInstall( input: { appName: \"Dummy Payment App\" manifestUrl: \"$manifest_url\" permissions: [HANDLE_PAYMENTS, HANDLE_CHECKOUTS] } ) { appInstallation { id status appName manifestUrl } appErrors { field message code } } }"
    
    local response=$(execute_graphql "$query" "$token")
    
    # 检查安装结果
    local result=$(echo "$response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    install_data = data.get('data', {}).get('appInstall', {})
    app_errors = install_data.get('appErrors', [])
    
    if app_errors:
        for error in app_errors:
            print(f\"ERROR: {error.get('message', 'Unknown error')}\")
    else:
        app_installation = install_data.get('appInstallation', {})
        if app_installation:
            status = app_installation.get('status', 'UNKNOWN')
            app_name = app_installation.get('appName', 'Unknown')
            print(f\"SUCCESS: {app_name} - Status: {status}\")
        else:
            print('ERROR: No installation data returned')
except Exception as e:
    print(f'ERROR: {str(e)}')
" 2>/dev/null)
    
    if [[ "$result" == SUCCESS:* ]]; then
        print_success "成功安装应用: ${result#SUCCESS: }"
        print_debug "新安装的应用使用的 manifestUrl: $manifest_url"
        return 0
    else
        print_error "安装失败: ${result#ERROR: }"
        print_debug "安装失败时使用的 manifestUrl: $manifest_url"
        return 1
    fi
}

# 验证安装
verify_installation() {
    local token="$1"
    
    print_step "验证" "安装状态..."
    
    # 检查安装状态
    local installations_query='query CheckInstallations { appsInstallations { id status appName manifestUrl createdAt } }'
    local installations_response=$(execute_graphql "$installations_query" "$token")
    
    # 检查应用列表
    local apps_query='query ListApps { apps(first: 10) { edges { node { id name isActive webhooks { name targetUrl } } } } }'
    local apps_response=$(execute_graphql "$apps_query" "$token")
    
    # 验证 Dummy Payment App 是否存在且活跃
    local verification=$(echo "$apps_response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    apps = data.get('data', {}).get('apps', {}).get('edges', [])
    for app in apps:
        node = app.get('node', {})
        if node.get('name') == 'Dummy Payment App' and node.get('isActive'):
            webhooks = node.get('webhooks', [])
            webhook_count = len(webhooks)
            print(f'SUCCESS: Dummy Payment App is active with {webhook_count} webhooks')
            sys.exit(0)
    print('ERROR: Dummy Payment App not found or not active')
except Exception as e:
    print(f'ERROR: {str(e)}')
" 2>/dev/null)
    
    if [[ "$verification" == SUCCESS:* ]]; then
        print_success "验证成功: ${verification#SUCCESS: }"
        return 0
    else
        print_error "验证失败: ${verification#ERROR: }"
        return 1
    fi
}

# 主流程
main() {
    print_step "1" "启动所有服务"
    ./s1_to_s4_start.sh
    
    print_step "2" "等待服务完全启动"
    wait_for_service "http://localhost:8000/graphql/" "Saleor GraphQL"
    wait_for_service "http://localhost:3001/api/manifest" "Dummy Payment App"
    
    print_step "3" "获取 ngrok forwarding URL"
    NGROK_URL=$(get_ngrok_url)
    if [ $? -ne 0 ]; then
        print_error "无法获取 ngrok URL，请检查 ngrok 是否正常运行"
        exit 1
    fi
    print_success "ngrok URL: $NGROK_URL"
    
    print_step "4" "获取认证 token"
    print_debug "测试 GraphQL 端点连接性..."
    local test_response=$(curl -s --connect-timeout 5 --max-time 10 -X POST \
        -H "Content-Type: application/json" \
        -d '{"query": "query { __typename }"}' \
        http://localhost:8000/graphql/ || echo "CURL_FAILED")
    
    if [[ "$test_response" == "CURL_FAILED" ]] || [ -z "$test_response" ]; then
        print_error "无法连接到 Saleor GraphQL 端点，请检查服务是否正常运行"
        print_debug "GraphQL 端点测试失败，响应: $test_response"
        exit 1
    else
        print_debug "GraphQL 端点连接正常，响应长度: ${#test_response}"
    fi
    
    print_debug "准备调用 get_auth_token 函数..."
    AUTH_TOKEN=$(get_auth_token)
    local auth_exit_code=$?
    print_debug "get_auth_token 函数调用完成，退出码: $auth_exit_code"
    print_debug "AUTH_TOKEN 内容长度: ${#AUTH_TOKEN}"
    
    if [ $auth_exit_code -ne 0 ] || [ -z "$AUTH_TOKEN" ]; then
        print_debug "进入分支: 获取认证 token 失败，脚本将退出"
        print_debug "AUTH_TOKEN 内容: '$AUTH_TOKEN'"
        exit 1
    else
        print_debug "进入分支: 成功获取认证 token"
        print_debug "获取到的 token (前20字符): ${AUTH_TOKEN:0:20}..."
    fi
    
    print_step "5" "查找并卸载旧的 Dummy Payment App"
    print_debug "开始调用 get_dummy_app_id 函数..."
    DUMMY_APP_ID=$(get_dummy_app_id "$AUTH_TOKEN")
    print_debug "get_dummy_app_id 函数调用完成，返回码: $?"
    if [ $? -eq 0 ]; then
        print_debug "进入分支: 找到了旧的 Dummy Payment App，开始卸载流程"
        uninstall_app "$AUTH_TOKEN" "$DUMMY_APP_ID"
        if [ $? -ne 0 ]; then
            print_debug "进入分支: 卸载失败，脚本将退出"
            exit 1
        fi
        print_debug "进入分支: 卸载成功，等待3秒后继续"
        # 等待卸载完成
        sleep 3
    else
        print_debug "进入分支: 未找到旧的 Dummy Payment App，跳过卸载步骤"
    fi
    
    print_step "6" "安装新的 Dummy Payment App"
    install_app "$AUTH_TOKEN" "$NGROK_URL"
    if [ $? -ne 0 ]; then
        print_debug "进入分支: 安装失败，脚本将退出"
        exit 1
    else
        print_debug "进入分支: 安装成功，继续执行"
    fi
    
    # 等待安装完成
    sleep 5
    
    print_step "7" "验证安装结果"
    verify_installation "$AUTH_TOKEN"
    if [ $? -ne 0 ]; then
        exit 1
    fi
    
    echo ""
    print_success "🎉 Dummy Payment App 重新安装完成！"
    echo -e "${GREEN}📋 安装信息:${NC}"
    echo -e "   • ngrok URL: ${BLUE}$NGROK_URL${NC}"
    echo -e "   • Manifest URL: ${BLUE}$NGROK_URL/api/manifest${NC}"
    echo -e "   • GraphQL Playground: ${BLUE}http://localhost:8000/graphql/${NC}"
    echo ""
}

# 检查依赖
check_dependencies() {
    local missing_deps=()
    
    if ! command -v curl &> /dev/null; then
        missing_deps+=("curl")
    fi
    
    if ! command -v python3 &> /dev/null; then
        missing_deps+=("python3")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "缺少依赖: ${missing_deps[*]}"
        echo "请安装缺少的依赖后重试"
        exit 1
    fi
}

# 脚本入口
echo "🔧 检查依赖..."
check_dependencies

echo "📁 当前目录: $(pwd)"
echo "📋 开始执行主流程..."
echo ""

main

echo ""
print_success "✨ 脚本执行完成！"
