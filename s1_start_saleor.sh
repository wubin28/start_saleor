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
        write text "cd /Users/binwu/OOR-local/katas/saleor/saleor-platform"
        
        -- 等待一小段时间确保命令执行完成
        delay 0.5
        
        -- 执行docker compose down命令
        write text "# 开始执行docker compose down命令"
        write text "docker compose down"
        delay 3
        
        -- 执行docker compose down -v命令
        write text "# 开始执行docker compose down -v命令"
        write text "docker compose down -v"
        delay 3
        
        -- 执行数据库迁移命令
        write text "# 开始执行数据库迁移命令"
        write text "docker compose run --rm api python3 manage.py migrate"
        delay 75
        
        -- 执行setup命令
        write text "# 开始执行setup命令"
        write text "docker compose run --rm api python3 manage.py setup"
        delay 3
        
        -- 执行populatedb命令
        write text "# 开始执行populatedb命令"
        write text "docker compose run --rm api python3 manage.py populatedb"
        delay 15
        
        -- 创建超级用户
        write text "# 开始创建超级用户"
        write text "docker compose run --rm -e DJANGO_SUPERUSER_USERNAME=admin -e DJANGO_SUPERUSER_EMAIL=admin@example.com -e DJANGO_SUPERUSER_PASSWORD=admin api python3 manage.py createsuperuser --noinput"
        delay 6
        
        -- 执行docker compose up命令
        write text "# 开始执行docker compose up命令"
        write text "docker compose up"
        delay 20
    end tell
end tell
EOF

echo "新的iTerm2窗口已打开，正在执行docker compose up命令..."