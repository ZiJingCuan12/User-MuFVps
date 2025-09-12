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

# 检测国家/地区
echo "正在检测网络环境..."
COUNTRY=$(curl -s https://ipinfo.io/country)
if [ -z "$COUNTRY" ]; then
    echo "⚠️  警告: 无法确定网络位置，使用默认设置 (US)"
    COUNTRY="US"
else
    # 根据国家代码提供更友好的提示
    if [ "$COUNTRY" = "CN" ]; then
        echo "✅ 检测到您的网络位于中国大陆，将使用国内镜像加速下载"
    else
        echo "✅ 检测到您的网络位于 $COUNTRY，将使用国际网络下载"
    fi
fi

# 使用提供的token下载并执行私有仓库的安装脚本
if [ "$COUNTRY" = "CN" ]; then
    echo "🇨🇳 使用国内镜像源下载安装脚本..."
    curl -L "https://gitee.com/live-to-death-1/mu-fvps01/raw/master/install.sh" \
        -o ./install.sh
else
    echo "🌍 使用GitHub源下载安装脚本..."
    curl -L -H "Authorization: token $TOKEN" \
        "https://raw.githubusercontent.com/ZiJingCuan12/MuFVps-panel/refs/heads/main/install.sh" \
        -o ./install.sh
fi

# 检查下载是否成功
if [ ! -f "./install.sh" ]; then
    echo "❌ 下载安装脚本失败!"
    exit 1
fi

chmod +x ./install.sh && \
./install.sh -a "$ADDRESS" -s "$SECRET" -c "$COUNTRY"

# 检查执行是否成功
if [ $? -eq 0 ]; then
    echo "安装成功完成!"
    # 清理临时文件
    rm -f ./install_panel.sh
else
    echo "安装过程中出现错误!"
    exit 1
fi