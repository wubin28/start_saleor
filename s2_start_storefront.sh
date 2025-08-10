#!/bin/bash

# iTerm2自动化脚本
# 功能：打开新的iTerm2窗口并执行指定命令

osascript <<EOF
tell application "iTerm"
    activate
    
    -- 创建新窗口
    create window with default profile
    
    -- 获取当前会话
    tell current session of current window
        -- 执行第一个命令：切换目录
        write text "cd /Users/binwu/OOR-local/katas/saleor/storefront/saleor-storefront-installed-manually-from-fork"
        
        -- 等待一小段时间确保命令执行完成
        delay 0.5
        
        -- 执行第二个命令：启动开发服务器
        write text "pnpm run dev"
    end tell
end tell
EOF

echo "新的iTerm2窗口已打开，正在执行pnpm run dev命令..."
