#!/bin/bash

# iTerm2自动化脚本
# 功能：打开新的iTerm2窗口并停止Saleor Platform容器

osascript <<EOF
tell application "iTerm"
    activate
    
    -- 创建新窗口
    create window with default profile
    
    -- 获取当前会话
    tell current session of current window
        -- 设置窗口标题
        set name to "Stop Saleor Platform"
        
        -- 执行第一个命令：切换目录
        write text "cd /Users/binwu/OOR-local/katas/saleor-platform"
        
        -- 等待一小段时间确保命令执行完成
        delay 0.5
        
        -- 显示停止信息
        write text "echo '正在停止Saleor Platform容器...'"
        
        -- 执行停止命令
        write text "docker compose down"
        
        -- 等待停止完成
        delay 2
        
        -- 显示完成信息
        write text "echo '✅ Saleor Platform容器已停止'"
        
        -- 显示容器状态确认
        write text "docker compose ps"
    end tell
end tell
EOF

echo "新的iTerm2窗口已打开，正在停止Saleor Platform容器..."