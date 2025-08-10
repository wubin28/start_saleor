#!/bin/bash

# 停止Saleor Platform容器脚本
# 功能：在当前终端窗口停止Saleor Platform容器

# 切换到Saleor Platform目录
cd /Users/binwu/OOR-local/katas/saleor/saleor-platform

# 显示停止信息
echo "正在停止Saleor Platform容器..."

# 执行停止命令
docker compose down

# 显示完成信息
echo "✅ Saleor Platform容器已停止"

# 显示容器状态确认
docker compose ps
