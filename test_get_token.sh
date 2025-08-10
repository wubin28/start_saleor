#!/bin/bash

# 测试脚本：专门用于调试获取 token 的功能

echo "🔍 测试获取 Auth Token..."

# 方法1：直接使用 curl（已证明可以工作）
echo "📋 方法1: 直接 curl 命令"
response=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{"query": "mutation { tokenCreate(email: \"admin@example.com\", password: \"admin\") { token user { email isStaff } errors { message } } }"}' \
  http://localhost:8000/graphql/)

echo "响应长度: ${#response}"
echo "响应前100字符: ${response:0:100}..."

# 提取 token
token=$(echo "$response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    token = data.get('data', {}).get('tokenCreate', {}).get('token', '')
    if token:
        print(token)
    else:
        print('ERROR: No token found')
except Exception as e:
    print(f'ERROR: {e}')
")

if [[ "$token" == ERROR:* ]]; then
    echo "❌ 提取 token 失败: ${token#ERROR: }"
else
    echo "✅ 成功提取 token"
    echo "Token 前50字符: ${token:0:50}..."
fi

echo ""
echo "📋 方法2: 使用变量构建查询"

# 使用变量构建查询
query='mutation { tokenCreate(email: "admin@example.com", password: "admin") { token user { email isStaff } errors { message } } }'
json_data="{\"query\": \"$query\"}"

echo "查询内容: $query"
echo "JSON 数据: $json_data"

response2=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d "$json_data" \
  http://localhost:8000/graphql/)

echo "响应长度: ${#response2}"

# 提取 token
token2=$(echo "$response2" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    token = data.get('data', {}).get('tokenCreate', {}).get('token', '')
    if token:
        print(token)
    else:
        errors = data.get('errors', [])
        if errors:
            print(f'ERROR: GraphQL errors: {errors}')
        else:
            print('ERROR: No token found in response')
except Exception as e:
    print(f'ERROR: JSON parse error: {e}')
")

if [[ "$token2" == ERROR:* ]]; then
    echo "❌ 方法2失败: ${token2#ERROR: }"
    echo "完整响应: $response2"
else
    echo "✅ 方法2成功"
    echo "Token 前50字符: ${token2:0:50}..."
fi

echo ""
echo "📋 方法3: 使用 Python 生成 JSON"

# 使用 Python 生成完整的 JSON
json_data3=$(python3 -c "
import json
query = 'mutation { tokenCreate(email: \"admin@example.com\", password: \"admin\") { token user { email isStaff } errors { message } } }'
print(json.dumps({'query': query}))
")

echo "Python 生成的 JSON: $json_data3"

response3=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d "$json_data3" \
  http://localhost:8000/graphql/)

echo "响应长度: ${#response3}"

# 提取 token
token3=$(echo "$response3" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    token = data.get('data', {}).get('tokenCreate', {}).get('token', '')
    if token:
        print(token)
    else:
        print('ERROR: No token found')
except Exception as e:
    print(f'ERROR: {e}')
")

if [[ "$token3" == ERROR:* ]]; then
    echo "❌ 方法3失败: ${token3#ERROR: }"
else
    echo "✅ 方法3成功"
    echo "Token 前50字符: ${token3:0:50}..."
fi

echo ""
echo "📋 测试完成！"