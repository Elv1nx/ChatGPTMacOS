#!/bin/bash

# ChatGPT macOS 应用运行脚本
# 用于快速启动应用进行开发和测试

set -e

echo "======================================"
echo "ChatGPT macOS 应用运行脚本"
echo "======================================"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DERIVED_DATA_DIR="$HOME/Library/Developer/Xcode/DerivedData"

echo -e "${BLUE}项目目录：$PROJECT_DIR${NC}"

# 检查 Xcode 是否安装
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}错误：未找到 Xcode，请先安装 Xcode${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Xcode 已安装${NC}"

# 检查项目文件
if [ ! -f "$PROJECT_DIR/ChatGPTMacOS.xcodeproj/project.pbxproj" ]; then
    echo -e "${RED}错误：未找到项目文件${NC}"
    exit 1
fi

echo -e "${GREEN}✓ 项目文件存在${NC}"

# 提供菜单选择
echo ""
echo "请选择操作:"
echo "1. 使用 Xcode 打开项目（推荐）"
echo "2. 构建 Debug 版本并运行"
echo "3. 构建 Release 版本"
echo "4. 清理构建缓存"
echo "5. 退出"
echo ""

read -p "$(echo -e $BLUE'请输入选项 (1-5): '$NC)" -n 1 -r
echo

case $REPLY in
    1)
        echo -e "${YELLOW}正在打开 Xcode 项目...${NC}"
        open "$PROJECT_DIR/ChatGPTMacOS.xcodeproj"
        echo -e "${GREEN}✓ Xcode 已启动${NC}"
        echo ""
        echo "提示:"
        echo "  1. 在 Xcode 中选择 Scheme: ChatGPTMacOS"
        echo "  2. 选择目标：My Mac"
        echo "  3. 点击运行按钮 (⌘R)"
        ;;
    2)
        echo -e "${YELLOW}开始构建 Debug 版本...${NC}"
        cd "$PROJECT_DIR"
        
        # 清理之前的构建
        echo -e "${BLUE}清理之前的构建...${NC}"
        xcodebuild clean -project ChatGPTMacOS.xcodeproj -scheme ChatGPTMacOS > /dev/null 2>&1
        
        # 构建
        echo -e "${BLUE}构建中...${NC}"
        if xcodebuild -project ChatGPTMacOS.xcodeproj \
            -scheme ChatGPTMacOS \
            -configuration Debug \
            -destination "platform=macOS" \
            build 2>&1 | tee /tmp/chatgpt_build.log; then
            
            echo -e "${GREEN}✓ 构建成功${NC}"
            
            # 查找应用
            APP_PATH=$(find "$DERIVED_DATA_DIR" -name "ChatGPT.app" -type d 2>/dev/null | grep Debug | head -1)
            
            if [ -n "$APP_PATH" ]; then
                echo -e "${GREEN}✓ 应用位置：$APP_PATH${NC}"
                echo ""
                read -p "$(echo -e $BLUE'是否现在运行应用？(y/n) '$NC)" -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    # 签名应用
                    echo -e "${BLUE}签名应用...${NC}"
                    codesign --force --deep --sign - "$APP_PATH" 2>/dev/null || true
                    
                    # 运行应用
                    echo -e "${BLUE}启动应用...${NC}"
                    open "$APP_PATH"
                    echo -e "${GREEN}✓ 应用已启动${NC}"
                fi
            else
                echo -e "${YELLOW}警告：未找到构建的应用${NC}"
                echo "请检查构建日志：/tmp/chatgpt_build.log"
            fi
        else
            echo -e "${RED}✗ 构建失败${NC}"
            echo "请查看错误日志或尝试使用 Xcode 打开项目"
        fi
        ;;
    3)
        echo -e "${YELLOW}开始构建 Release 版本...${NC}"
        cd "$PROJECT_DIR"
        
        if xcodebuild -project ChatGPTMacOS.xcodeproj \
            -scheme ChatGPTMacOS \
            -configuration Release \
            -destination "platform=macOS" \
            build; then
            
            echo -e "${GREEN}✓ Release 构建成功${NC}"
            
            # 查找应用
            APP_PATH=$(find "$DERIVED_DATA_DIR" -name "ChatGPT.app" -type d 2>/dev/null | grep Release | head -1)
            
            if [ -n "$APP_PATH" ]; then
                echo -e "${GREEN}✓ 应用位置：$APP_PATH${NC}"
                echo ""
                echo "您可以:"
                echo "  1. 直接运行：open $APP_PATH"
                echo "  2. 复制到 Applications: cp -R $APP_PATH /Applications/"
            fi
        else
            echo -e "${RED}✗ Release 构建失败${NC}"
        fi
        ;;
    4)
        echo -e "${YELLOW}清理构建缓存...${NC}"
        rm -rf "$DERIVED_DATA_DIR/ChatGPTMacOS"*
        echo -e "${GREEN}✓ 缓存已清理${NC}"
        ;;
    5)
        echo -e "${BLUE}退出${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}无效选项${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}完成！${NC}"
