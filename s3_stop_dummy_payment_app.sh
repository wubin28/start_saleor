#!/bin/bash

# 查找运行在3001端口上的进程
PID=$(lsof -i :3001 -t)

if [ -z "$PID" ]; then
    echo "没有找到运行在3001端口上的进程，dummy payment app可能已经停止。"
    exit 0
fi

echo "找到运行在3001端口上的进程，PID: $PID，正在停止..."

# 尝试优雅地终止进程
kill $PID

# 等待一小段时间
sleep 2

# 检查进程是否仍在运行
if ps -p $PID > /dev/null; then
    echo "进程仍在运行，尝试强制终止..."
    kill -9 $PID
    
    # 再次检查
    sleep 1
    if ps -p $PID > /dev/null; then
        echo "无法终止进程，请手动关闭。"
        exit 1
    else
        echo "进程已成功强制终止。"
    fi
else
    echo "进程已成功终止。"
fi

echo "dummy payment app 已停止。"
