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

# 使用提供的token下载并执行私有仓库的安装脚本
curl -L -H "Authorization: token $TOKEN" \
    "https://raw.githubusercontent.com/ZiJingCuan12/MuFVps-panel/refs/heads/main/install.sh" \
    -o ./install.sh && \
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