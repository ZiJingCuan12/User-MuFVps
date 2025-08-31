#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== MuFVps Panel 安装程序 ===${NC}"

# 要求用户输入 token
read -sp "请输入访问令牌(token): " USER_TOKEN
echo ""

# 简单的 token 验证（实际中可以更复杂）
if [ -z "$USER_TOKEN" ]; then
    echo -e "${RED}错误：token 不能为空！${NC}"
    exit 1
fi

# 使用 token 访问私有仓库的安装脚本
PRIVATE_SCRIPT_URL="https://raw.githubusercontent.com/ZiJingCuan12/MuFVps-panel/main/panel_install.sh"

echo -e "${YELLOW}正在下载安装脚本...${NC}"

# 使用 curl 带 token 访问（GitHub raw 内容需要认证）
curl -L -H "Authorization: token $USER_TOKEN" \
     -H "Accept: application/vnd.github.v3.raw" \
     "$PRIVATE_SCRIPT_URL" -o panel_install.sh

# 检查下载是否成功
if [ $? -ne 0 ] || [ ! -f "panel_install.sh" ]; then
    echo -e "${RED}下载失败！请检查：${NC}"
    echo "1. Token 是否正确"
    echo "2. 是否有权限访问该仓库"
    echo "3. 网络连接是否正常"
    exit 1
fi

# 添加执行权限
chmod +x panel_install.sh

echo -e "${GREEN}下载成功！开始安装...${NC}"

# 执行安装脚本
./panel_install.sh

# 清理（可选）
# rm -f panel_install.sh