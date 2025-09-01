#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 显示欢迎信息
echo -e "${BLUE}==============================================${NC}"
echo -e "${GREEN}        MuFVps Panel 安装脚本${NC}"
echo -e "${BLUE}==============================================${NC}"
echo ""

# 请求用户输入 token
echo -e "${YELLOW}请输入访问令牌 (Token):${NC}"
read -s -p "Token: " USER_TOKEN
echo ""

# 验证 token 是否为空
if [ -z "$USER_TOKEN" ]; then
    echo -e "${RED}错误：Token 不能为空！${NC}"
    exit 1
fi

# 设置 GitHub raw 内容 URL（使用用户提供的 token）
GITHUB_RAW_URL="https://raw.githubusercontent.com/ZiJingCuan12/MuFVps-panel/main/panel_install.sh"
AUTH_URL="https://${USER_TOKEN}@raw.githubusercontent.com/ZiJingCuan12/MuFVps-panel/main/panel_install.sh"

echo -e "${YELLOW}正在验证 Token 并下载安装脚本...${NC}"

# 尝试使用提供的 token 下载脚本
response=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $USER_TOKEN" \
    -L "https://api.github.com/repos/ZiJingCuan12/MuFVps-panel/contents/panel_install.sh" 2>/dev/null)

# 检查 HTTP 响应码
if [ "$response" -eq 200 ]; then
    echo -e "${GREEN}Token 验证成功！${NC}"
    
    # 下载安装脚本
    if curl -H "Authorization: token $USER_TOKEN" -L "$GITHUB_RAW_URL" -o panel_install.sh; then
        echo -e "${GREEN}脚本下载成功！${NC}"
        
        # 添加执行权限
        chmod +x panel_install.sh
        
        echo -e "${YELLOW}正在执行安装脚本...${NC}"
        echo -e "${BLUE}==============================================${NC}"
        
        # 执行安装脚本
        USER_TOKEN="$USER_TOKEN" ./panel_install.sh
        
    else
        echo -e "${RED}错误：下载脚本失败！${NC}"
        echo -e "${YELLOW}请检查："
        echo "1. Token 是否正确"
        echo "2. 网络连接是否正常"
        echo "3. 仓库是否存在 panel_install.sh 文件${NC}"
        exit 1
    fi
    
elif [ "$response" -eq 401 ] || [ "$response" -eq 403 ]; then
    echo -e "${RED}错误：Token 无效或权限不足！${NC}"
    echo -e "${YELLOW}请检查："
    echo "1. Token 是否正确"
    echo "2. Token 是否具有访问仓库的权限"
    echo "3. Token 是否已过期${NC}"
    exit 1
    
elif [ "$response" -eq 404 ]; then
    echo -e "${RED}错误：仓库或文件不存在！${NC}"
    echo -e "${YELLOW}请检查仓库路径是否正确${NC}"
    exit 1
    
else
    echo -e "${RED}错误：无法访问仓库 (HTTP: $response)${NC}"
    echo -e "${YELLOW}请检查网络连接或稍后重试${NC}"
    exit 1
fi

# 清理临时文件（如果需要）
cleanup() {
    if [ -f "panel_install.sh" ]; then
        rm -f panel_install.sh
    fi
}

# 设置退出时清理
trap cleanup EXIT

echo -e "${GREEN}安装完成！${NC}"