#!/bin/bash

# 调试脚本：精确定位 token 获取失败的原因

echo "🔍 开始调试 token 获取问题..."
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_debug() { echo -e "${YELLOW}🔍 $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

# 步骤1：测试基本连接
echo "===== 步骤1：测试基本连接 ====="
test_response=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d '{"query": "query { __typename }"}' \
    http://localhost:8000/graphql/ 2>&1)

if [ -n "$test_response" ]; then
    print_success "GraphQL 端点可访问"
    echo "响应: $test_response"
else
    print_error "GraphQL 端点不可访问"
    exit 1
fi

echo ""
echo "===== 步骤2：直接 curl 获取 token（已验证可工作）====="
direct_response=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d '{"query": "mutation { tokenCreate(email: \"admin@example.com\", password: \"admin\") { token user { email isStaff } errors { message } } }"}' \
    http://localhost:8000/graphql/)

echo "直接 curl 响应长度: ${#direct_response}"
echo "响应前100字符: ${direct_response:0:100}..."

# 提取 token
direct_token=$(echo "$direct_response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    token = data.get('data', {}).get('tokenCreate', {}).get('token', '')
    if token:
        print(token)
    else:
        print('NO_TOKEN')
except Exception as e:
    print(f'PARSE_ERROR: {e}')
")

if [[ "$direct_token" != "NO_TOKEN" ]] && [[ "$direct_token" != PARSE_ERROR:* ]]; then
    print_success "直接 curl 成功获取 token"
    echo "Token 前50字符: ${direct_token:0:50}..."
else
    print_error "直接 curl 获取 token 失败: $direct_token"
fi

echo ""
echo "===== 步骤3：测试 Python JSON 生成 ====="
query='mutation { tokenCreate(email: "admin@example.com", password: "admin") { token user { email isStaff } errors { message } } }'
echo "原始查询: $query"

json_data=$(python3 -c "
import json
query = '''$query'''
print(json.dumps({'query': query}))
" 2>&1)

python_exit_code=$?
echo "Python 退出码: $python_exit_code"
echo "生成的 JSON: $json_data"

echo ""
echo "===== 步骤4：使用生成的 JSON 发送请求 ====="
if [ $python_exit_code -eq 0 ] && [ -n "$json_data" ]; then
    python_response=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -d "$json_data" \
        http://localhost:8000/graphql/ 2>&1)
    
    curl_exit_code=$?
    echo "curl 退出码: $curl_exit_code"
    echo "响应长度: ${#python_response}"
    echo "响应前100字符: ${python_response:0:100}..."
    
    # 尝试提取 token
    python_token=$(echo "$python_response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    token_data = data.get('data', {}).get('tokenCreate', {})
    token = token_data.get('token', '')
    errors = token_data.get('errors', [])
    
    if errors:
        error_msgs = [e.get('message', 'Unknown error') for e in errors]
        print('ERRORS: ' + ', '.join(error_msgs))
    elif token:
        print(token)
    else:
        print('NO_TOKEN')
except Exception as e:
    print(f'PARSE_ERROR: {e}')
" 2>&1)
    
    if [[ "$python_token" != "NO_TOKEN" ]] && [[ "$python_token" != PARSE_ERROR:* ]] && [[ "$python_token" != ERRORS:* ]]; then
        print_success "Python 方法成功获取 token"
        echo "Token 前50字符: ${python_token:0:50}..."
    else
        print_error "Python 方法获取 token 失败: $python_token"
        echo "完整响应: $python_response"
    fi
else
    print_error "无法生成 JSON"
fi

echo ""
echo "===== 步骤5：模拟脚本中的函数调用 ====="

# 模拟 execute_graphql 函数
execute_graphql_test() {
    local query="$1"
    
    print_debug "execute_graphql_test: 开始"
    
    # 生成 JSON
    local json_data=$(python3 -c "
import json
query = '''$query'''
print(json.dumps({'query': query}))
" 2>/dev/null)
    
    local json_exit_code=$?
    print_debug "JSON 生成退出码: $json_exit_code"
    
    if [ $json_exit_code -ne 0 ] || [ -z "$json_data" ]; then
        print_error "无法生成 JSON"
        echo ""
        return 1
    fi
    
    print_debug "JSON 数据: $json_data"
    
    # 发送请求
    local curl_result=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -d "$json_data" \
        http://localhost:8000/graphql/ 2>&1)
    
    local curl_exit_code=$?
    print_debug "curl 退出码: $curl_exit_code"
    
    if [ $curl_exit_code -ne 0 ]; then
        print_error "curl 失败"
        echo ""
        return 1
    fi
    
    if [ -z "$curl_result" ]; then
        print_error "响应为空"
        echo ""
        return 1
    fi
    
    print_debug "响应长度: ${#curl_result}"
    echo "$curl_result"
    return 0
}

# 模拟 get_auth_token 函数
get_auth_token_test() {
    print_info "模拟 get_auth_token 函数..."
    
    local query='mutation { tokenCreate(email: "admin@example.com", password: "admin") { token user { email isStaff } errors { message } } }'
    
    print_debug "查询: $query"
    
    local response=$(execute_graphql_test "$query")
    local execute_exit_code=$?
    
    print_debug "execute_graphql_test 退出码: $execute_exit_code"
    print_debug "response 变量内容长度: ${#response}"
    print_debug "response 变量内容前100字符: ${response:0:100}..."
    
    if [ $execute_exit_code -ne 0 ]; then
        print_error "execute_graphql_test 调用失败"
        return 1
    fi
    
    if [ -z "$response" ]; then
        print_error "响应为空"
        return 1
    fi
    
    # 提取 token
    local token=$(echo "$response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    token_data = data.get('data', {}).get('tokenCreate', {})
    token = token_data.get('token', '')
    errors = token_data.get('errors', [])
    
    if errors:
        error_msgs = [e.get('message', 'Unknown error') for e in errors]
        print('ERROR: ' + ', '.join(error_msgs))
    elif token:
        print(token)
    else:
        print('ERROR: No token in response')
except Exception as e:
    print('ERROR: JSON parse error: ' + str(e))
" 2>&1)
    
    local parse_exit_code=$?
    print_debug "Python 解析退出码: $parse_exit_code"
    print_debug "提取的 token: ${token:0:50}..."
    
    if [[ "$token" == ERROR:* ]]; then
        print_error "Token 提取失败: ${token#ERROR: }"
        return 1
    elif [ -n "$token" ]; then
        print_success "成功获取 token"
        echo "$token"
        return 0
    else
        print_error "未知错误"
        return 1
    fi
}

# 运行测试
echo "运行函数模拟测试..."
TEST_TOKEN=$(get_auth_token_test)
test_exit_code=$?

echo ""
echo "===== 最终结果 ====="
if [ $test_exit_code -eq 0 ] && [ -n "$TEST_TOKEN" ]; then
    print_success "✅ 函数模拟成功！"
    echo "获取到的 Token 前50字符: ${TEST_TOKEN:0:50}..."
else
    print_error "❌ 函数模拟失败"
    echo "退出码: $test_exit_code"
    echo "Token 变量内容: '$TEST_TOKEN'"
fi

echo ""
echo "===== 步骤6：检查子shell问题 ====="
echo "测试子shell返回值..."

# 测试子shell
test_subshell() {
    echo "test output"
    return 0
}

SUBSHELL_RESULT=$(test_subshell)
subshell_exit=$?
echo "子shell 退出码: $subshell_exit"
echo "子shell 结果: '$SUBSHELL_RESULT'"

# 测试带错误的子shell
test_subshell_error() {
    echo "test output"
    return 1
}

SUBSHELL_ERROR=$(test_subshell_error)
subshell_error_exit=$?
echo "错误子shell 退出码: $subshell_error_exit"
echo "错误子shell 结果: '$SUBSHELL_ERROR'"

echo ""
print_info "调试完成！"