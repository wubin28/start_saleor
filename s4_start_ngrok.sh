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
        -- 执行命令：启动ngrok
        write text "ngrok http 3001"
    end tell
end tell
EOF

echo "新的iTerm2窗口已打开，正在执行ngrok http 3001命令..."