#!/bin/bash

# ChatGPT macOS 应用快速构建脚本
# 使用 swiftc 直接编译

set -e

echo "======================================"
echo "ChatGPT macOS 快速构建脚本"
echo "======================================"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$PROJECT_DIR/build_output"
APP_NAME="ChatGPT.app"
APP_PATH="$BUILD_DIR/$APP_NAME"

echo -e "${BLUE}项目目录：$PROJECT_DIR${NC}"

# 清理之前的构建
echo -e "${YELLOW}清理之前的构建...${NC}"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# 检查 Swift 是否可用
if ! command -v swiftc &> /dev/null; then
    echo -e "${RED}错误：未找到 swiftc，请先安装 Xcode Command Line Tools${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Swift 编译器已就绪${NC}"

# 收集所有源文件
echo -e "${BLUE}收集源文件...${NC}"
SOURCE_FILES=""
for file in "$PROJECT_DIR"/temp_sources/*.swift; do
    if [ -f "$file" ]; then
        echo -e "  ✓ $(basename "$file")"
        SOURCE_FILES="$SOURCE_FILES $file"
    fi
done

if [ -z "$SOURCE_FILES" ]; then
    echo -e "${RED}错误：未找到 Swift 源文件${NC}"
    exit 1
fi

# 编译应用
echo -e "\n${YELLOW}开始编译...${NC}"
echo -e "${BLUE}目标：macOS x86_64${NC}"
echo -e "${BLUE}输出：$APP_PATH${NC}"

# 创建 App 包结构
mkdir -p "$APP_PATH/Contents/MacOS"
mkdir -p "$APP_PATH/Contents/Resources"

# 复制资源文件
if [ -f "$PROJECT_DIR/Resources/Info.plist" ]; then
    cp "$PROJECT_DIR/Resources/Info.plist" "$APP_PATH/Contents/"
    echo -e "${GREEN}✓ 复制 Info.plist${NC}"
fi

if [ -f "$PROJECT_DIR/Resources/Entitlements.plist" ]; then
    cp "$PROJECT_DIR/Resources/Entitlements.plist" "$APP_PATH/Contents/Resources/"
    echo -e "${GREEN}✓ 复制 Entitlements.plist${NC}"
fi

# 编译 Swift 文件
echo -e "\n${YELLOW}编译 Swift 代码...${NC}"
swiftc -sdk $(xcrun --show-sdk-path) \
    -target x86_64-apple-macos13.0 \
    -o "$APP_PATH/Contents/MacOS/ChatGPT" \
    $SOURCE_FILES \
    -module-name ChatGPT \
    -emit-executable

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ 编译成功${NC}"
else
    echo -e "${RED}✗ 编译失败${NC}"
    exit 1
fi

# 签名应用
echo -e "\n${YELLOW}签名应用...${NC}"
codesign --force --deep --sign - "$APP_PATH"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ 签名成功${NC}"
else
    echo -e "${YELLOW}⚠ 签名失败，但应用可能仍可运行${NC}"
fi

# 显示结果
echo -e "\n${GREEN}======================================"
echo "构建完成！"
echo "======================================${NC}"
echo -e "应用位置：${YELLOW}$APP_PATH${NC}"
echo -e "\n您可以:"
echo "  1. 直接运行：open $APP_PATH"
echo "  2. 复制到 Applications: cp -R $APP_PATH /Applications/"
echo ""

# 询问是否运行
read -p "$(echo -e $BLUE'是否现在运行应用？(y/n) '$NC)" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}启动应用...${NC}"
    open "$APP_PATH"
    echo -e "${GREEN}✓ 应用已启动${NC}"
fi
