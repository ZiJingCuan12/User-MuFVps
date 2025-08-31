#!/bin/bash

# 显示使用说明
echo "=== Flux 节点安装程序 ==="
echo ""

# 要求用户输入 token
read -sp "请输入访问令牌(MuFVps token): " USER_TOKEN
echo ""
echo ""

# 简单的 token 验证
if [ -z "$USER_TOKEN" ]; then
    echo "错误：token 不能为空！"
    exit 1
fi

echo "正在执行安装..."
echo ""

# 直接使用 token 访问私有仓库的安装脚本并传递所有参数
curl -L -H "Authorization: token $USER_TOKEN" \
     -H "Accept: application/vnd.github.v3.raw" \
     "https://raw.githubusercontent.com/ZiJingCuan12/MuFVps-panel/refs/heads/main/install.sh" \
     | bash -s -- "$@"
