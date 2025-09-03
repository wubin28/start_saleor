#!/bin/bash

# 功能：清理Saleor数据

# 切换到saleor-platform目录
cd /Users/binwu/OOR-local/katas/saleor/saleor-platform

echo "# 开始执行docker compose down命令"
docker compose down

echo "# 开始执行docker compose down -v命令删除所有数据卷以清空数据"
docker compose down -v

echo "数据清理完成..."
