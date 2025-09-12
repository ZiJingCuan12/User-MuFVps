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

# 下载脚本函数
download_script() {
    local source=$1
    local url=$2
    local output="$TEMP_DIR/install-jiedian.sh"

    echo "尝试从 $source 下载安装脚本..."
    if [ "$source" = "gitee" ]; then
        # 使用curl并禁止进度输出，同时将stderr重定向到/dev/null
        curl -s -L "$url" -o "$output" 2>/dev/null
    else
        # 从GitHub下载，使用token
        curl -s -L -H "Authorization: token $TOKEN" "$url" -o "$output" 2>/dev/null
    fi

    # 检查下载是否成功（文件存在且非空）
    if [ -s "$output" ]; then
        # 检查文件开头是否为bash脚本
        if head -n 1 "$output" | grep -q "bash"; then
            echo "✅ 从 $source 下载成功"
            return 0
        else
            echo "❌ 从 $source 下载的脚本格式不正确"
            rm -f "$output"
            return 1
        fi
    else
        echo "❌ 从 $source 下载失败或文件为空"
        rm -f "$output"
        return 1
    fi
}

# 根据国家选择下载源，如果第一个源失败则尝试另一个
if [ "$COUNTRY" = "CN" ]; then
    # 先尝试Gitee
    if download_script "gitee" "https://gitee.com/live-to-death-1/mu-fvps01/raw/master/install-jiedian.sh"; then
        echo "使用Gitee源下载的脚本"
    else
        echo "Gitee源下载失败，尝试使用GitHub源（可能需要代理）..."
        if download_script "github" "https://raw.githubusercontent.com/ZiJingCuan12/MuFVps-panel/refs/heads/main/install-jiedian.sh"; then
            echo "使用GitHub源下载的脚本"
        else
            echo "❌ 所有下载源均失败，请检查网络连接和token是否正确"
            rm -rf "$TEMP_DIR"
            exit 1
        fi
    fi
else
    # 国际用户直接使用GitHub
    if download_script "github" "https://raw.githubusercontent.com/ZiJingCuan12/MuFVps-panel/refs/heads/main/install-jiedian.sh"; then
        echo "使用GitHub源下载的脚本"
    else
        echo "❌ GitHub源下载失败，请检查网络连接和token是否正确"
        rm -rf "$TEMP_DIR"
        exit 1
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