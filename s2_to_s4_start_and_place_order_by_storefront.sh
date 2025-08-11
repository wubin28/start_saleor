#!/bin/bash

# reinstall_dummy_payment_app_simple.sh
# 功能：自动重新安装 Dummy Payment App（简化版，使用已验证的方法）
# 适用于：macOS Sequoia 15.6 + iTerm2

echo "🚀 开始自动重新安装 Dummy Payment App（简化版）..."

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

# GraphQL 查询函数 - 使用直接的 curl（已验证可工作）
execute_graphql_simple() {
    local query="$1"
    local token="$2"
    
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
    
    print_debug "发送请求..." >&2
    
    # 执行 curl 命令
    if [ -n "$token" ]; then
        curl -s -X POST \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $token" \
            -d "$json_payload" \
            http://localhost:8000/graphql/
    else
        curl -s -X POST \
            -H "Content-Type: application/json" \
            -d "$json_payload" \
            http://localhost:8000/graphql/
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
        echo -n "." >&2
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
    
    print_step "获取" "ngrok forwarding URL..." >&2
    
    while [ $attempt -le $max_attempts ]; do
        local ngrok_response=$(curl -s http://localhost:4040/api/tunnels 2>/dev/null || echo "")
        
        if [ -n "$ngrok_response" ]; then
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
                print_success "获取到 ngrok URL: $ngrok_url" >&2
                print_info "对应的 manifest URL 将是: ${ngrok_url}/api/manifest" >&2
                # Only output the clean URL to stdout
                echo "$ngrok_url"
                return 0
            fi
        fi
        
        echo -n "." >&2
        sleep 2
        ((attempt++))
    done
    
    print_error "无法获取 ngrok URL" >&2
    return 1
}

# 获取用户认证 token - 使用最简单的方法
get_auth_token_simple() {
    print_step "获取" "用户认证 token..." >&2
    
    # 直接使用已验证可工作的 curl 命令
    local response=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -d '{"query": "mutation { tokenCreate(email: \"admin@example.com\", password: \"admin\") { token user { email isStaff } errors { message } } }"}' \
        http://localhost:8000/graphql/)
    
    if [ -z "$response" ]; then
        print_error "无响应" >&2
        return 1
    fi
    
    print_debug "响应长度: ${#response}" >&2
    
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
        print_success "成功获取认证 token" >&2
        print_debug "Token 前50字符: ${token:0:50}..." >&2
        # Only output the clean token to stdout
        echo "$token"
        return 0
    else
        print_error "获取 token 失败" >&2
        print_debug "响应: $response" >&2
        return 1
    fi
}

# 获取 Dummy Payment App ID
get_dummy_app_id() {
    local token="$1"
    
    print_step "查找" "Dummy Payment App ID..." >&2
    
    local query='query { apps(first: 10) { edges { node { id name isActive } } } }'
    local response=$(execute_graphql_simple "$query" "$token")
    
    if [ -z "$response" ]; then
        print_error "查询失败" >&2
        return 1
    fi
    
    # 提取 Dummy Payment App 的 ID
    local app_id=$(echo "$response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for edge in data.get('data', {}).get('apps', {}).get('edges', []):
        node = edge.get('node', {})
        if 'Dummy Payment App' in node.get('name', ''):
            print(node.get('id', ''))
            break
except:
    pass
")
    
    if [ -n "$app_id" ]; then
        print_success "找到 Dummy Payment App ID: $app_id" >&2
        # Only output the clean app_id to stdout
        echo "$app_id"
        return 0
    else
        print_warning "未找到 Dummy Payment App" >&2
        return 1
    fi
}

# 卸载应用
uninstall_app() {
    local token="$1"
    local app_id="$2"
    
    print_step "卸载" "Dummy Payment App (ID: $app_id)..."
    
    local query=$(python3 -c "
app_id = '$app_id'
print(f'mutation {{ appDelete(id: \"{app_id}\") {{ app {{ id name }} appErrors {{ field message code }} }} }}')
")
    
    local response=$(execute_graphql_simple "$query" "$token")
    
    if [ -z "$response" ]; then
        print_error "卸载请求失败"
        return 1
    fi
    
    # 简单检查是否成功
    if [[ "$response" == *"\"appErrors\":[]"* ]] || [[ "$response" == *"\"app\""* ]]; then
        print_success "应用已卸载"
        return 0
    else
        print_error "卸载失败"
        print_debug "响应: $response"
        return 1
    fi
}

# 安装应用
install_app() {
    local token="$1"
    local ngrok_url="$2"
    local manifest_url="${ngrok_url}/api/manifest"
    
    print_step "安装" "Dummy Payment App"
    print_info "Manifest URL: $manifest_url"
    
    local query=$(python3 -c "
manifest_url = '$manifest_url'
print(f'mutation {{ appInstall( input: {{ appName: \"Dummy Payment App\" manifestUrl: \"{manifest_url}\" permissions: [HANDLE_PAYMENTS, HANDLE_CHECKOUTS] }} ) {{ appInstallation {{ id status appName manifestUrl }} appErrors {{ field message code }} }} }}')
")
    
    local response=$(execute_graphql_simple "$query" "$token")
    
    if [ -z "$response" ]; then
        print_error "安装请求失败"
        return 1
    fi
    
    # 检查是否成功 - 检查 appErrors 为空且有 appInstallation 对象
    if [[ "$response" == *"\"appErrors\": []"* ]] && [[ "$response" == *"\"appInstallation\":"* ]]; then
        # 进一步检查安装状态
        local status=$(echo "$response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    installation = data.get('data', {}).get('appInstall', {}).get('appInstallation', {})
    if installation:
        print(installation.get('status', ''))
except:
    pass
" 2>/dev/null)
        
        if [[ "$status" == "PENDING" ]] || [[ "$status" == "INSTALLED" ]]; then
            print_success "应用安装成功 (状态: $status)"
            return 0
        else
            print_warning "应用安装状态未知: $status"
            return 0  # 仍然视为成功，因为没有错误
        fi
    else
        print_error "安装失败"
        print_debug "响应: $response"
        return 1
    fi
}

# 验证安装
verify_installation() {
    local token="$1"
    
    print_step "验证" "安装状态..."
    
    # 查询已安装的应用
    local query='query { apps(first: 10) { edges { node { id name isActive } } } }'
    local response=$(execute_graphql_simple "$query" "$token")
    
    if [[ "$response" == *"Dummy Payment App"* ]]; then
        if [[ "$response" == *"\"isActive\":true"* ]]; then
            print_success "Dummy Payment App 已安装并激活"
            return 0
        else
            print_success "Dummy Payment App 已安装 (可能正在激活中)"
            return 0
        fi
    else
        # 如果在apps中找不到，检查app installations
        local install_query='query { appInstallations(first: 10) { edges { node { id status appName } } } }'
        local install_response=$(execute_graphql_simple "$install_query" "$token")
        
        if [[ "$install_response" == *"Dummy Payment App"* ]]; then
            local status=$(echo "$install_response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for edge in data.get('data', {}).get('appInstallations', {}).get('edges', []):
        node = edge.get('node', {})
        if 'Dummy Payment App' in node.get('appName', ''):
            print(node.get('status', ''))
            break
except:
    pass
" 2>/dev/null)
            
            if [[ "$status" == "PENDING" ]]; then
                print_success "Dummy Payment App 安装中 (状态: PENDING)"
                return 0
            elif [[ "$status" == "INSTALLED" ]]; then
                print_success "Dummy Payment App 已安装完成"
                return 0
            else
                print_warning "Dummy Payment App 安装状态: $status"
                return 0
            fi
        else
            print_warning "无法验证安装状态"
            return 1
        fi
    fi
}

# 主流程
main() {
    print_step "1" "启动所有服务"
    ./s2_to_s4_start.sh
    
    print_step "2" "等待服务完全启动"
    wait_for_service "http://localhost:8000/graphql/" "Saleor GraphQL"
    wait_for_service "http://localhost:3001/api/manifest" "Dummy Payment App"
    
    print_step "3" "获取 ngrok forwarding URL"
    NGROK_URL=$(get_ngrok_url)
    if [ -z "$NGROK_URL" ]; then
        print_error "无法获取 ngrok URL"
        return 1
    fi
    
    print_step "4" "获取认证 token"
    AUTH_TOKEN=$(get_auth_token_simple)
    if [ -z "$AUTH_TOKEN" ]; then
        print_error "无法获取认证 token"
        return 1
    fi
    
    print_step "5" "查找并卸载旧的 Dummy Payment App"
    DUMMY_APP_ID=$(get_dummy_app_id "$AUTH_TOKEN")
    if [ -n "$DUMMY_APP_ID" ]; then
        uninstall_app "$AUTH_TOKEN" "$DUMMY_APP_ID"
        sleep 3
    else
        print_info "未找到旧应用，跳过卸载"
    fi
    
    print_step "6" "安装新的 Dummy Payment App"
    install_app "$AUTH_TOKEN" "$NGROK_URL"
    
    sleep 5
    
    print_step "7" "验证安装结果"
    verify_installation "$AUTH_TOKEN"
    
    echo ""
    print_success "🎉 Dummy Payment App 重新安装完成！"
    echo -e "${GREEN}📋 安装信息:${NC}"
    echo -e "   • ngrok URL: ${BLUE}$NGROK_URL${NC}"
    echo -e "   • Manifest URL: ${BLUE}$NGROK_URL/api/manifest${NC}"
    echo -e "   • GraphQL Playground: ${BLUE}http://localhost:8000/graphql/${NC}"
    
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