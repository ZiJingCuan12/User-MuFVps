#!/bin/bash

# 显示用法信息
usage() {
    echo "用法: $0 -a <地址> -s <密钥>"
    echo "示例: ./install-jiedian.sh -a 118.145.87.187:6365 -s 985e69528e4a4475afd8d8745ddacef7"
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

# 创建临时目录用于下载
TEMP_DIR=$(mktemp -d)
echo "使用临时目录: $TEMP_DIR"

# 使用提供的token下载并执行私有仓库的安装脚本
if [ "$COUNTRY" = "CN" ]; then
    echo "🇨🇳 使用国内镜像源下载安装脚本..."
    # 使用wget替代curl，并添加适当的选项来处理Gitee的响应
    if command -v wget &> /dev/null; then
        wget --quiet --output-document="$TEMP_DIR/install-jiedian.sh" \
            "https://gitee.com/live-to-death-1/mu-fvps01/raw/master/install-jiedian.sh"
    else
        # 如果wget不可用，使用curl但添加-s选项来禁止进度显示
        curl -s -L "https://gitee.com/live-to-death-1/mu-fvps01/raw/master/install-jiedian.sh" \
            -o "$TEMP_DIR/install-jiedian.sh"
    fi
else
    echo "🌍 使用GitHub源下载安装脚本..."
    curl -s -L -H "Authorization: token $TOKEN" \
        "https://raw.githubusercontent.com/ZiJingCuan12/MuFVps-panel/refs/heads/main/install-jiedian.sh" \
        -o "$TEMP_DIR/install-jiedian.sh"
fi

# 检查下载是否成功
if [ ! -f "$TEMP_DIR/install-jiedian.sh" ]; then
    echo "❌ 下载安装脚本失败!"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# 检查文件是否包含有效内容（不是错误页面）
if ! head -n 1 "$TEMP_DIR/install-jiedian.sh" | grep -q "bash"; then
    echo "❌ 下载的脚本文件格式不正确!"
    echo "文件开头内容:"
    head -n 5 "$TEMP_DIR/install-jiedian.sh"
    echo "尝试清理文件内容..."
    
    # 尝试清理文件，移除可能包含的curl进度信息
    sed -i '/^[0-9% ]/d' "$TEMP_DIR/install-jiedian.sh"
    sed -i '/^ *#/!b; /^ *#!/!d' "$TEMP_DIR/install-jiedian.sh"
    
    # 再次检查
    if ! head -n 1 "$TEMP_DIR/install-jiedian.sh" | grep -q "bash"; then
        echo "❌ 无法修复脚本文件，请检查网络连接或手动下载脚本"
        rm -rf "$TEMP_DIR"
        exit 1
    else
        echo "✅ 脚本文件已修复"
    fi
fi

# 添加执行权限并运行
chmod +x "$TEMP_DIR/install-jiedian.sh"
cd "$TEMP_DIR" && \
./install-jiedian.sh -a "$ADDRESS" -s "$SECRET" -c "$COUNTRY"

# 检查执行是否成功
if [ $? -eq 0 ]; then
    echo "安装成功完成!"
    # 清理临时文件
    rm -rf "$TEMP_DIR"
else
    echo "安装过程中出现错误!"
    rm -rf "$TEMP_DIR"
    exit 1
fi