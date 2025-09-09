#!/bin/bash

# 显示用法信息
usage() {
    echo "用法: $0 -a <地址> -s <密钥>"
    echo "示例: ./install.sh -a 118.145.87.187:6365 -s 985e69528e4a4475afd8d8745ddacef7"
    exit 1
}

# 解析命令行参数
while getopts ":a:s:" opt; do
    case $opt in
        a) ADDRESS="$OPTARG" ;;
        s) SECRET="$OPTARG" ;;
        *) usage ;;
    esac
done

# 检查必要参数
if [ -z "$ADDRESS" ] || [ -z "$SECRET" ]; then
    usage
fi

# 请求用户输入token
echo "请输入访问token:"
read -s TOKEN

# 验证token是否提供
if [ -z "$TOKEN" ]; then
    echo "错误: 必须提供token!"
    exit 1
fi

# 根据国家代码选择下载源
if [ "$COUNTRY" = "CN" ]; then
    echo "检测到国内环境，使用Gitee源下载..."
    DOWNLOAD_URL="https://gitee.com/live-to-death-1/mu-fvps01/raw/master/install.sh"
    # 国内源下载（不需要token）
    curl -L --retry 3 --connect-timeout 30 --max-time 60 \
        "$DOWNLOAD_URL" -o ./install.sh
else
    echo "使用GitHub源下载..."
    DOWNLOAD_URL="https://raw.githubusercontent.com/ZiJingCuan12/MuFVps-panel/refs/heads/main/install.sh"
    # GitHub源下载（需要token认证）
    curl -L -H "Authorization: token $TOKEN" \
        --retry 3 --connect-timeout 30 --max-time 60 \
        "$DOWNLOAD_URL" -o ./install.sh
fi

# 检查下载是否成功
if [ $? -ne 0 ] || [ ! -f "./install.sh" ]; then
    echo "错误: 下载安装脚本失败!"
    exit 1
fi

# 赋予执行权限并执行安装
chmod +x ./install.sh && \
./install.sh -a "$ADDRESS" -s "$SECRET"

# 检查执行是否成功
if [ $? -eq 0 ]; then
    echo "安装成功完成!"
    # 清理临时文件
    rm -f ./install_panel.sh
else
    echo "安装过程中出现错误!"
    exit 1
fi