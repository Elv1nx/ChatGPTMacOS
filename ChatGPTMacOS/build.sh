#!/bin/bash

# ChatGPT macOS 应用打包脚本
# 适用于 Intel 平台 Mac

set -e

echo "======================================"
echo "ChatGPT macOS 应用打包脚本"
echo "======================================"

# 配置变量
PROJECT_NAME="ChatGPTMacOS"
SCHEME_NAME="ChatGPTMacOS"
BUILD_DIR="./build"
ARCHIVE_DIR="./build/archive"
EXPORT_DIR="./build/export"
APP_NAME="ChatGPT.app"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查 Xcode 是否安装
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}错误：未找到 Xcode，请先安装 Xcode${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Xcode 已安装${NC}"

# 清理之前的构建
echo -e "\n${YELLOW}清理之前的构建...${NC}"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# 检查架构
ARCH=$(uname -m)
echo -e "\n${YELLOW}当前系统架构：$ARCH${NC}"

if [ "$ARCH" = "x86_64" ]; then
    echo -e "${GREEN}✓ Intel 平台已确认${NC}"
    PLATFORM="macosx"
    DESTINATION="platform=macOS,arch=x86_64"
else
    echo -e "${YELLOW}警告：当前不是 Intel 平台，将尝试构建通用架构${NC}"
    PLATFORM="macosx"
    DESTINATION="platform=macOS"
fi

# 构建项目
echo -e "\n${YELLOW}开始构建项目...${NC}"
xcodebuild -project "$PROJECT_NAME.xcodeproj" \
    -scheme "$SCHEME_NAME" \
    -configuration Release \
    -destination "$DESTINATION" \
    -derivedDataPath "$BUILD_DIR/derived" \
    -archivePath "$ARCHIVE_DIR/$PROJECT_NAME.xcarchive" \
    archive

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ 构建成功${NC}"
else
    echo -e "${RED}✗ 构建失败${NC}"
    exit 1
fi

# 导出应用
echo -e "\n${YELLOW}导出应用...${NC}"
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_DIR/$PROJECT_NAME.xcarchive" \
    -exportPath "$EXPORT_DIR" \
    -exportOptionsPlist "./Resources/ExportOptions.plist"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ 导出成功${NC}"
else
    echo -e "${RED}✗ 导出失败${NC}"
    exit 1
fi

# 显示结果
echo -e "\n${GREEN}======================================"
echo "打包完成！"
echo "======================================${NC}"
echo -e "应用位置：${YELLOW}$EXPORT_DIR/$APP_NAME${NC}"
echo -e "\n您可以："
echo "  1. 直接双击运行 $EXPORT_DIR/$APP_NAME"
echo "  2. 将应用拖拽到 /Applications 目录"
echo "  3. 使用以下命令签名："
echo "     codesign --force --deep --sign - $EXPORT_DIR/$APP_NAME"

# 可选：自动签名
read -p "$(echo -e $YELLOW'是否自动签名应用？(y/n) '$NC)" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    codesign --force --deep --sign - "$EXPORT_DIR/$APP_NAME"
    echo -e "${GREEN}✓ 签名完成${NC}"
fi

echo -e "\n${GREEN}祝使用愉快！${NC}"
