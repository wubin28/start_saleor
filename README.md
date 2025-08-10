# Saleor 本地下单系统

这是一个在 macOS 本地环境中运行 Saleor 电商系统并完成下单流程的项目。本项目包含了启动 Saleor、Storefront、Dummy Payment App 和 ngrok 的脚本，以及重新安装 Dummy Payment App 的自动化脚本。

## 系统要求

- macOS 操作系统
- Docker Desktop
- iTerm2 终端
- 网络浏览器

## 使用方法

### 1. 启动服务

1. **手动启动 Docker Desktop**
   - 在 macOS 上打开 Docker Desktop 应用
   - 等待 Docker 引擎完全启动（状态栏图标变为稳定状态）

2. **启动所有服务**
   - 打开 iTerm2 终端
   - 进入项目目录：
     ```bash
     cd /Users/binwu/OOR-local/katas/saleor/start_saleor
     ```
   - 运行saleor启动脚本（该脚本会依次启动 saleor、storefront、dummy payment app 和 ngrok 并安装 dummy payment app）：
     ```bash
     ./s1_to_s4_start_and_reinstall_dummy_payment_app.sh
     ```
   - 等待所有服务启动完成，终端会显示成功信息和相关 URL

### 2. 在 Storefront 中下单

1. **访问 Storefront**
   - 在浏览器中打开：[http://localhost:3000/](http://localhost:3000/)
   - 浏览商品并将商品添加到购物车

2. **完成下单流程**
   - 进入购物车页面
   - 点击结账按钮
   - 填写配送信息
   - 选择支付方式（将使用已配置的 Dummy Payment App）
   - 确认订单

### 3. 停止所有服务

当您完成测试后，可以使用以下命令停止所有服务：

```bash
./s4_to_s1_stop.sh
```

该命令会按照启动的逆序依次关闭 ngrok、dummy payment app、storefront 和 saleor 服务。

## 脚本说明

- `s1_to_s4_start_and_reinstall_dummy_payment_app.sh` - 自动按顺序启动所有服务并安装 Dummy Payment App
- `s1_to_s4_start.sh` - 按顺序启动所有服务
- `s4_to_s1_stop.sh` - 按顺序停止所有服务
- `s1_start_saleor.sh` - 单独启动 Saleor 服务
- `s2_start_storefront.sh` - 单独启动 Storefront 服务
- `s3_start_dummy_payment_app.sh` - 单独启动 Dummy Payment App 服务
- `s4_start_ngrok.sh` - 单独启动 ngrok 服务

## 注意事项

- 确保在运行脚本前 Docker Desktop 已经完全启动
- 首次启动可能需要较长时间，因为需要下载和构建 Docker 镜像
- 如果遇到问题，可以尝试重新运行 `s1_to_s4_start_and_reinstall_dummy_payment_app.sh` 脚本
