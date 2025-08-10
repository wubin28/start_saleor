#!/bin/bash

# iTerm2自动化脚本
# 功能：打开新的iTerm2窗口并停止Storefront开发服务器

osascript <<EOF
tell application "iTerm"
    activate
    
    -- 创建新窗口
    create window with default profile
    
    -- 获取当前会话
    tell current session of current window
        -- 设置窗口标题
        set name to "Stop Storefront"
        
        -- 显示停止信息
        write text "echo '正在停止Storefront开发服务器...'"
        
        -- 等待一小段时间
        delay 0.5
        
        -- 查找并停止pnpm dev进程
        write text "pkill -f 'pnpm.*dev'"
        
        -- 等待停止完成
        delay 1
        
        -- 查找并停止node进程（如果有残留的node进程）
        write text "pkill -f 'saleor-storefront'"
        
        -- 等待停止完成
        delay 1
        
        -- 显示完成信息
        write text "echo '✅ Storefront开发服务器已停止'"
        
        -- 显示进程状态确认
        write text "echo '检查相关进程状态:'"
        write text "ps aux | grep -E '(pnpm|node).*dev' | grep -v grep || echo '没有发现相关进程'"
    end tell
end tell
EOF

echo "新的iTerm2窗口已打开，正在停止Storefront开发服务器..."
