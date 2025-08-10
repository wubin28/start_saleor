#!/bin/bash

# s1_to_s4_start.sh
# 功能：按顺序启动多个服务，并在每个服务启动后等待指定的时间

echo "开始启动所有服务..."

# 1. 运行 s1_start_saleor.sh
echo "步骤 1/4: 启动 Saleor..."
bash /Users/binwu/OOR-local/katas/start_saleor/s1_start_saleor.sh

# 2. 等待30秒，确保 Saleor 启动完成
echo "等待 30 秒，确保 Saleor 启动完成..."
sleep 30

# 3. 运行 s2_start_storefront.sh
echo "步骤 2/4: 启动 Storefront..."
bash /Users/binwu/OOR-local/katas/start_saleor/s2_start_storefront.sh

# 4. 等待5秒
echo "等待 5 秒..."
sleep 5

# 5. 运行 s3_start_dummy_payment_app.sh
echo "步骤 3/4: 启动 Dummy Payment App..."
bash /Users/binwu/OOR-local/katas/start_saleor/s3_start_dummy_payment_app.sh

# 6. 等待5秒
echo "等待 5 秒..."
sleep 5

# 7. 运行 s4_start_ngrok.sh
echo "步骤 4/4: 启动 Ngrok..."
bash /Users/binwu/OOR-local/katas/start_saleor/s4_start_ngrok.sh

# 8. 等待5秒
echo "等待 5 秒..."
sleep 5

echo "所有服务已启动完成！"
