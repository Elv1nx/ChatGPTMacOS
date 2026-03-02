#!/bin/bash

# ChatGPT macOS 应用运行脚本（使用 Xcode）
# 这个脚本会尝试使用 Xcode 构建并运行应用

set -e

echo "======================================"
echo "ChatGPT macOS 应用运行脚本"
echo "======================================"

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DERIVED_DATA="$HOME/Library/Developer/Xcode/DerivedData"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}项目目录：$PROJECT_DIR${NC}"

# 检查 Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}错误：未找到 Xcode${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Xcode 已安装${NC}"

# 清理 DerivedData
echo -e "${YELLOW}清理缓存...${NC}"
rm -rf "$DERIVED_DATA/ChatGPTMacOS"* 2>/dev/null || true

# 使用 xcodebuild 构建
echo -e "\n${YELLOW}开始构建...${NC}"
cd "$PROJECT_DIR"

# 尝试构建
if xcodebuild -project ChatGPTMacOS.xcodeproj \
    -scheme ChatGPTMacOS \
    -configuration Debug \
    -destination "platform=macOS" \
    -derivedDataPath "$PROJECT_DIR/build_derived" \
    build 2>&1 | tee /tmp/chatgpt_build.log; then
    
    echo -e "\n${GREEN}✓ 构建成功${NC}"
    
    # 查找应用
    APP_PATH=$(find "$PROJECT_DIR/build_derived" -name "ChatGPT.app" -type d 2>/dev/null | head -1)
    
    if [ -n "$APP_PATH" ]; then
        echo -e "${GREEN}✓ 应用位置：$APP_PATH${NC}"
        
        # 签名
        echo -e "${BLUE}签名应用...${NC}"
        codesign --force --deep --sign - "$APP_PATH" 2>/dev/null || echo -e "${YELLOW}⚠ 签名可能失败${NC}"
        
        # 运行
        echo -e "\n${BLUE}启动应用...${NC}"
        open "$APP_PATH"
        echo -e "${GREEN}✓ 应用已启动${NC}"
        
        echo -e "\n${GREEN}======================================"
        echo "成功！"
        echo "======================================${NC}"
    else
        echo -e "${RED}✗ 未找到构建的应用${NC}"
        exit 1
    fi
else
    echo -e "\n${RED}✗ 构建失败${NC}"
    echo -e "${YELLOW}请查看日志：/tmp/chatgpt_build.log${NC}"
    echo ""
    echo -e "${BLUE}建议的解决方案:${NC}"
    echo "  1. 打开 Xcode: open ChatGPTMacOS.xcodeproj"
    echo "  2. 在 Xcode 中手动构建和运行"
    echo "  3. 查看错误日志并修复问题"
    exit 1
fi
