#!/bin/bash

# 停止Storefront开发服务器脚本
# 功能：在当前终端窗口停止Storefront开发服务器

echo "正在停止Storefront开发服务器..."

# 查找并停止pnpm dev进程
pkill -f 'pnpm.*dev'

# 等待停止完成
sleep 1

# 查找并停止node进程（如果有残留的node进程）
pkill -f 'saleor-storefront'

# 等待停止完成
sleep 1

# 显示完成信息
echo "✅ Storefront开发服务器已停止"

# 显示进程状态确认
echo "检查相关进程状态:"
ps aux | grep -E '(pnpm|node).*dev' | grep -v grep || echo "没有发现相关进程"
