#!/bin/bash

# ChatGPT macOS 应用测试脚本

set -e

echo "======================================"
echo "ChatGPT macOS 应用测试"
echo "======================================"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 测试 1: 检查项目文件
echo -e "\n${YELLOW}测试 1: 检查项目文件...${NC}"
if [ -f "./ChatGPTMacOS.xcodeproj/project.pbxproj" ]; then
    echo -e "${GREEN}✓ 项目文件存在${NC}"
else
    echo -e "${RED}✗ 项目文件不存在${NC}"
    exit 1
fi

# 测试 2: 检查源代码
echo -e "\n${YELLOW}测试 2: 检查源代码...${NC}"
SOURCE_FILES=(
    "Sources/ChatGPTApp.swift"
    "Sources/AppState.swift"
    "Sources/ContentView.swift"
    "Sources/LoginView.swift"
    "Sources/ChatView.swift"
    "Sources/HeaderView.swift"
    "Sources/WebViewContainer.swift"
)

for file in "${SOURCE_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓ $file${NC}"
    else
        echo -e "${RED}✗ $file 不存在${NC}"
        exit 1
    fi
done

# 测试 3: 检查配置文件
echo -e "\n${YELLOW}测试 3: 检查配置文件...${NC}"
CONFIG_FILES=(
    "Resources/Info.plist"
    "Resources/Entitlements.plist"
    "Resources/ExportOptions.plist"
)

for file in "${CONFIG_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓ $file${NC}"
    else
        echo -e "${RED}✗ $file 不存在${NC}"
        exit 1
    fi
done

# 测试 4: 清理构建
echo -e "\n${YELLOW}测试 4: 清理构建...${NC}"
xcodebuild clean -project ChatGPTMacOS.xcodeproj -scheme ChatGPTMacOS
echo -e "${GREEN}✓ 清理完成${NC}"

# 测试 5: 编译检查
echo -e "\n${YELLOW}测试 5: 编译检查...${NC}"
xcodebuild -project ChatGPTMacOS.xcodeproj \
    -scheme ChatGPTMacOS \
    -configuration Debug \
    -destination "platform=macOS" \
    build

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ 编译成功${NC}"
else
    echo -e "${RED}✗ 编译失败${NC}"
    exit 1
fi

# 测试 6: 运行单元测试（如果有）
echo -e "\n${YELLOW}测试 6: 运行单元测试...${NC}"
echo -e "${YELLOW}暂无单元测试${NC}"

echo -e "\n${GREEN}======================================"
echo "所有测试通过！"
echo "======================================${NC}"
