#!/bin/bash

# s1_to_s4_stop.sh
# 功能：按照启动的逆序关闭所有服务，并在每个服务关闭后等待指定的时间

echo "开始关闭所有服务..."

# 1. 运行 s4_stop_ngrok.sh
echo "步骤 1/4: 关闭 Ngrok..."
bash /Users/binwu/OOR-local/katas/saleor/start_saleor/s4_stop_ngrok.sh

# 2. 等待1秒
echo "等待 1 秒..."
sleep 1

# 3. 运行 s3_stop_dummy_payment_app.sh
echo "步骤 2/4: 关闭 Dummy Payment App..."
bash /Users/binwu/OOR-local/katas/saleor/start_saleor/s3_stop_dummy_payment_app.sh

# 4. 等待1秒
echo "等待 1 秒..."
sleep 1

# 5. 运行 s2_stop_storefront.sh
echo "步骤 3/4: 关闭 Storefront..."
bash /Users/binwu/OOR-local/katas/saleor/start_saleor/s2_stop_storefront.sh

# 6. 等待1秒
echo "等待 1 秒..."
sleep 1

# 7. 运行 s1_stop_saleor.sh
echo "步骤 4/4: 关闭 Saleor..."
bash /Users/binwu/OOR-local/katas/saleor/start_saleor/s1_stop_saleor.sh

# 8. 等待1秒
echo "等待 1 秒..."
sleep 1

echo "所有服务已关闭完成！"
