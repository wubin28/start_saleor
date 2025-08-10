#!/bin/bash

# 查找ngrok进程
NGROK_PID=$(pgrep ngrok)

if [ -z "$NGROK_PID" ]; then
    echo "未找到运行中的ngrok进程"
else
    # 终止ngrok进程
    echo "正在停止ngrok进程 (PID: $NGROK_PID)..."
    kill $NGROK_PID
    
    # 检查进程是否已终止
    sleep 1
    if pgrep -x ngrok > /dev/null; then
        echo "ngrok进程未能正常终止，尝试强制终止..."
        kill -9 $NGROK_PID
        echo "ngrok进程已强制终止"
    else
        echo "ngrok进程已成功终止"
    fi
fi
