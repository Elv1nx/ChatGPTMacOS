# ChatGPT macOS Native Client

## 📋 项目概述

**ChatGPT macOS 原生客户端**是一个使用 Swift 5.9+ 和 SwiftUI 构建的 macOS 应用，通过 WebKit 嵌入 ChatGPT 网页，提供原生的聊天体验。

- **快速登录**: 通过 WebView 嵌入官方登录页面
- **原生体验**: 使用 SwiftUI 构建现代化界面
- **安全可靠**: 基于官方 WebKit 引擎，无第三方依赖
- **易于维护**: 清晰的 MVVM 架构设计

## ✨ 功能特性

- ✅ **网页登录**: 嵌入官方 ChatGPT 登录页面，支持账号密码登录
- ✅ **自动登录检测**: 智能判断登录状态，自动跳转到聊天界面
- ✅ **原生聊天视图**: 现代化 SwiftUI 界面，嵌入 ChatGPT 网页
- ✅ **一键退出**: 便捷的退出登录功能，清除会话数据
- ✅ **状态管理**: 完整的应用状态管理，提供流畅的用户体验
- ✅ **错误处理**: 完善的错误提示机制，确保应用稳定运行
- ✅ **响应式设计**: 自适应窗口大小，支持不同屏幕尺寸

## 🛠 技术栈

| 组件 | 技术选择 | 版本要求 |
|------|----------|----------|
| 编程语言 | Swift | 5.9.2+ |
| UI 框架 | SwiftUI | 原生支持 |
| WebView 引擎 | WebKit (WKWebView) | 原生支持 |
| 架构模式 | MVVM | - |
| 构建工具 | Xcode | 15.2+ |
| 部署目标 | macOS | 13.0+ |
| 支持架构 | Intel (x86_64) | 原生支持 |

## 🚀 快速开始

### 方法一：使用 Xcode（推荐）

**步骤 1: 打开项目**
```bash
cd /Users/elvinx/chatgpt-cn/ChatGPTMacOS
open ChatGPTMacOS.xcodeproj
```

**步骤 2: 配置签名**
1. 在 Xcode 中选择项目
2. 进入 "Signing & Capabilities" 标签
3. 选择你的 Team（或个人签名）
4. 确保 Bundle Identifier 唯一

**步骤 3: 运行应用**
1. 等待 Xcode 索引完成
2. 确保顶部选择 `ChatGPTMacOS` Scheme
3. 点击运行按钮 (▶️) 或按 `⌘R`
4. 应用启动后，在登录页面输入 OpenAI 账号密码

**步骤 4: 开始聊天**
- 登录成功后自动进入聊天界面
- 可以直接在嵌入的网页中与 ChatGPT 对话

### 方法二：命令行构建

**构建应用**:
```bash
cd /Users/elvinx/chatgpt-cn/ChatGPTMacOS

# 清理之前的构建
xcodebuild clean -project ChatGPTMacOS.xcodeproj -scheme ChatGPTMacOS

# 构建 Debug 版本
xcodebuild -project ChatGPTMacOS.xcodeproj \
    -scheme ChatGPTMacOS \
    -configuration Debug \
    -destination "platform=macOS" \
    build
```

**运行应用**:
```bash
open ~/Library/Developer/Xcode/DerivedData/ChatGPTMacOS-*/Build/Products/Debug/ChatGPT.app
```

## 📁 项目结构

```
ChatGPTMacOS/
├── Sources/                    # 源代码目录
│   ├── ChatGPTApp.swift        # 应用入口
│   ├── AppState.swift          # 应用状态管理
│   ├── ContentView.swift       # 主视图
│   ├── LoginView.swift         # 登录页面
│   ├── ChatView.swift          # 聊天页面
│   ├── HeaderView.swift        # 头部栏
│   └── WebViewContainer.swift  # WebView 容器
├── Resources/                  # 资源文件
│   ├── Info.plist              # 应用配置
│   ├── Entitlements.plist      # 权限配置
│   └── ExportOptions.plist     # 导出配置
├── ChatGPTMacOS.xcodeproj/     # Xcode 项目
│   └── project.pbxproj
├── build.sh                    # 打包脚本
├── test.sh                     # 测试脚本
├── README.md                   # 项目说明
├── DEVELOPMENT_REPORT.md       # 开发报告
└── TROUBLESHOOTING.md          # 问题排查指南
```

## 📦 打包应用

### 使用打包脚本

```bash
cd /Users/elvinx/chatgpt-cn/ChatGPTMacOS
chmod +x build.sh
./build.sh
```

打包完成后，应用位于 `build/export/ChatGPT.app`

### 手动打包

```bash
# 1. 归档
xcodebuild -project ChatGPTMacOS.xcodeproj \
    -scheme ChatGPTMacOS \
    -configuration Release \
    -archivePath ./build/ChatGPT.xcarchive \
    archive

# 2. 导出
xcodebuild -exportArchive \
    -archivePath ./build/ChatGPT.xcarchive \
    -exportPath ./build/export \
    -exportOptionsPlist Resources/ExportOptions.plist
```

## 🔧 常见问题

### Q1: 应用提示"已损坏"，无法打开

**解决方案**:
```bash
# 移除隔离属性
xattr -cr /path/to/ChatGPT.app

# 重新签名
codesign --force --deep --sign - /path/to/ChatGPT.app
```

### Q2: 编译失败，找不到源文件

**解决方案**:
1. 清理 DerivedData:
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```
2. 重新打开 Xcode 项目
3. 重新构建

### Q3: 无法访问 ChatGPT

**解决方案**:
- 检查网络连接
- 清除 DNS 缓存：`sudo dscacheutil -flushcache`
- 尝试使用代理或网络加速工具

### Q4: WebView 无法加载页面

**解决方案**:
- 检查 Info.plist 中的 ATS 配置
- 确认 Entitlements.plist 配置正确
- 重启应用

## 📝 使用说明

### 登录流程

1. 启动应用后，会自动打开 ChatGPT 登录页面
2. 输入你的 OpenAI 账号和密码
3. 完成验证（如果需要）
4. 登录成功后自动进入聊天界面

### 聊天功能

- 在聊天界面可以直接与 ChatGPT 对话
- 所有功能与网页版一致
- 支持发送消息、查看历史、复制内容等

### 退出登录

1. 点击右上角的"退出登录"按钮
2. 确认退出
3. 应用会返回登录界面

## 🔐 安全提示

- ⚠️ **不要**在公共电脑上使用
- ⚠️ **不要**将应用分享给他人使用
- ⚠️ 定期更改 OpenAI 账号密码
- ⚠️ 退出时确认清除会话
- ✅ 应用不会存储你的密码
- ✅ 所有数据都存储在本地
- ✅ 使用系统默认的安全机制

## 🚀 性能优化

### 加快启动速度

```bash
# 清理缓存
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# 使用 Release 模式构建（更快）
xcodebuild -project ChatGPTMacOS.xcodeproj \
    -scheme ChatGPTMacOS \
    -configuration Release \
    build
```

### 减少内存占用

- 定期清理 WebView 缓存
- 避免同时打开多个窗口
- 长时间不用时退出应用

## 🧪 测试

### 运行测试脚本

```bash
cd /Users/elvinx/chatgpt-cn/ChatGPTMacOS
chmod +x test.sh
./test.sh
```

**测试项目**:
- ✅ 项目文件检查
- ✅ 源代码文件检查
- ✅ 配置文件检查
- ✅ 清理构建
- ✅ 编译检查

## 📚 开发指南

### 环境要求

- macOS 13.0 或更高版本
- Xcode 15.0 或更高版本
- Swift 5.9 或更高版本

### 开发流程

1. **克隆/进入项目目录**
2. **打开 Xcode 项目**
3. **配置签名**
4. **运行应用**
5. **测试功能**
6. **打包应用**

## 🔄 后续改进

### 功能增强

- [ ] 消息通知支持
- [ ] 多账号切换
- [ ] 聊天记录导出
- [ ] 快捷键支持
- [ ] 系统托盘集成

### 性能优化

- [ ] 实现本地缓存
- [ ] 优化 WebView 性能
- [ ] 减少内存占用

### 用户体验

- [ ] 暗黑模式完善
- [ ] 自定义主题
- [ ] 多语言支持
- [ ] 辅助功能支持

## 📞 获取帮助

如果遇到其他问题：

1. 查看 `TROUBLESHOOTING.md` 获取详细排查指南
2. 查看 `DEVELOPMENT_REPORT.md` 了解开发详情
3. 检查 Xcode 控制台错误信息
4. 查看 macOS 系统日志

## 📄 许可证

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🌟 贡献

Contributions are welcome! Please feel free to submit a Pull Request.

## 📅 版本历史

- **1.0.0** (2026-03-02): 初始版本
  - 完成 macOS 原生应用架构
  - 实现 WebView 嵌入登录功能
  - 实现聊天界面和状态管理
  - 创建完整的构建和测试脚本

## 📞 联系

- **Project Link**: [https://github.com/Elv1nx/ChatGPTMacOS](https://github.com/Elv1nx/ChatGPTMacOS)
- **Issues**: [https://github.com/Elv1nx/ChatGPTMacOS/issues](https://github.com/Elv1nx/ChatGPTMacOS/issues)

---

**最后更新**: 2026-03-03  
**版本**: 1.0.0  
**作者**: AI Assistant# ChatGPT macOS Native Client

## 📋 项目概述

**ChatGPT macOS 原生客户端**是一个使用 Swift 5.9+ 和 SwiftUI 构建的 macOS 应用，通过 WebKit 嵌入 ChatGPT 网页，提供原生的聊天体验。

- **快速登录**: 通过 WebView 嵌入官方登录页面
- **原生体验**: 使用 SwiftUI 构建现代化界面
- **安全可靠**: 基于官方 WebKit 引擎，无第三方依赖
- **易于维护**: 清晰的 MVVM 架构设计

## ✨ 功能特性

- ✅ **网页登录**: 嵌入官方 ChatGPT 登录页面，支持账号密码登录
- ✅ **自动登录检测**: 智能判断登录状态，自动跳转到聊天界面
- ✅ **原生聊天视图**: 现代化 SwiftUI 界面，嵌入 ChatGPT 网页
- ✅ **一键退出**: 便捷的退出登录功能，清除会话数据
- ✅ **状态管理**: 完整的应用状态管理，提供流畅的用户体验
- ✅ **错误处理**: 完善的错误提示机制，确保应用稳定运行
- ✅ **响应式设计**: 自适应窗口大小，支持不同屏幕尺寸

## 🛠 技术栈

| 组件 | 技术选择 | 版本要求 |
|------|----------|----------|
| 编程语言 | Swift | 5.9.2+ |
| UI 框架 | SwiftUI | 原生支持 |
| WebView 引擎 | WebKit (WKWebView) | 原生支持 |
| 架构模式 | MVVM | - |
| 构建工具 | Xcode | 15.2+ |
| 部署目标 | macOS | 13.0+ |
| 支持架构 | Intel (x86_64) | 原生支持 |

## 🚀 快速开始

### 方法一：使用 Xcode（推荐）

**步骤 1: 打开项目**
```bash
cd /Users/elvinx/chatgpt-cn/ChatGPTMacOS
open ChatGPTMacOS.xcodeproj
```

**步骤 2: 配置签名**
1. 在 Xcode 中选择项目
2. 进入 "Signing & Capabilities" 标签
3. 选择你的 Team（或个人签名）
4. 确保 Bundle Identifier 唯一

**步骤 3: 运行应用**
1. 等待 Xcode 索引完成
2. 确保顶部选择 `ChatGPTMacOS` Scheme
3. 点击运行按钮 (▶️) 或按 `⌘R`
4. 应用启动后，在登录页面输入 OpenAI 账号密码

**步骤 4: 开始聊天**
- 登录成功后自动进入聊天界面
- 可以直接在嵌入的网页中与 ChatGPT 对话

### 方法二：命令行构建

**构建应用**:
```bash
cd /Users/elvinx/chatgpt-cn/ChatGPTMacOS

# 清理之前的构建
xcodebuild clean -project ChatGPTMacOS.xcodeproj -scheme ChatGPTMacOS

# 构建 Debug 版本
xcodebuild -project ChatGPTMacOS.xcodeproj \
    -scheme ChatGPTMacOS \
    -configuration Debug \
    -destination "platform=macOS" \
    build
```

**运行应用**:
```bash
open ~/Library/Developer/Xcode/DerivedData/ChatGPTMacOS-*/Build/Products/Debug/ChatGPT.app
```

## 📁 项目结构

```
ChatGPTMacOS/
├── Sources/                    # 源代码目录
│   ├── ChatGPTApp.swift        # 应用入口
│   ├── AppState.swift          # 应用状态管理
│   ├── ContentView.swift       # 主视图
│   ├── LoginView.swift         # 登录页面
│   ├── ChatView.swift          # 聊天页面
│   ├── HeaderView.swift        # 头部栏
│   └── WebViewContainer.swift  # WebView 容器
├── Resources/                  # 资源文件
│   ├── Info.plist              # 应用配置
│   ├── Entitlements.plist      # 权限配置
│   └── ExportOptions.plist     # 导出配置
├── ChatGPTMacOS.xcodeproj/     # Xcode 项目
│   └── project.pbxproj
├── build.sh                    # 打包脚本
├── test.sh                     # 测试脚本
├── README.md                   # 项目说明
├── DEVELOPMENT_REPORT.md       # 开发报告
└── TROUBLESHOOTING.md          # 问题排查指南
```

## 📦 打包应用

### 使用打包脚本

```bash
cd /Users/elvinx/chatgpt-cn/ChatGPTMacOS
chmod +x build.sh
./build.sh
```

打包完成后，应用位于 `build/export/ChatGPT.app`

### 手动打包

```bash
# 1. 归档
xcodebuild -project ChatGPTMacOS.xcodeproj \
    -scheme ChatGPTMacOS \
    -configuration Release \
    -archivePath ./build/ChatGPT.xcarchive \
    archive

# 2. 导出
xcodebuild -exportArchive \
    -archivePath ./build/ChatGPT.xcarchive \
    -exportPath ./build/export \
    -exportOptionsPlist Resources/ExportOptions.plist
```

## 🔧 常见问题

### Q1: 应用提示"已损坏"，无法打开

**解决方案**:
```bash
# 移除隔离属性
xattr -cr /path/to/ChatGPT.app

# 重新签名
codesign --force --deep --sign - /path/to/ChatGPT.app
```

### Q2: 编译失败，找不到源文件

**解决方案**:
1. 清理 DerivedData:
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```
2. 重新打开 Xcode 项目
3. 重新构建

### Q3: 无法访问 ChatGPT

**解决方案**:
- 检查网络连接
- 清除 DNS 缓存：`sudo dscacheutil -flushcache`
- 尝试使用代理或网络加速工具

### Q4: WebView 无法加载页面

**解决方案**:
- 检查 Info.plist 中的 ATS 配置
- 确认 Entitlements.plist 配置正确
- 重启应用

## 📝 使用说明

### 登录流程

1. 启动应用后，会自动打开 ChatGPT 登录页面
2. 输入你的 OpenAI 账号和密码
3. 完成验证（如果需要）
4. 登录成功后自动进入聊天界面

### 聊天功能

- 在聊天界面可以直接与 ChatGPT 对话
- 所有功能与网页版一致
- 支持发送消息、查看历史、复制内容等

### 退出登录

1. 点击右上角的"退出登录"按钮
2. 确认退出
3. 应用会返回登录界面

## 🔐 安全提示

- ⚠️ **不要**在公共电脑上使用
- ⚠️ **不要**将应用分享给他人使用
- ⚠️ 定期更改 OpenAI 账号密码
- ⚠️ 退出时确认清除会话
- ✅ 应用不会存储你的密码
- ✅ 所有数据都存储在本地
- ✅ 使用系统默认的安全机制

## 🚀 性能优化

### 加快启动速度

```bash
# 清理缓存
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# 使用 Release 模式构建（更快）
xcodebuild -project ChatGPTMacOS.xcodeproj \
    -scheme ChatGPTMacOS \
    -configuration Release \
    build
```

### 减少内存占用

- 定期清理 WebView 缓存
- 避免同时打开多个窗口
- 长时间不用时退出应用

## 🧪 测试

### 运行测试脚本

```bash
cd /Users/elvinx/chatgpt-cn/ChatGPTMacOS
chmod +x test.sh
./test.sh
```

**测试项目**:
- ✅ 项目文件检查
- ✅ 源代码文件检查
- ✅ 配置文件检查
- ✅ 清理构建
- ✅ 编译检查

## 📚 开发指南

### 环境要求

- macOS 13.0 或更高版本
- Xcode 15.0 或更高版本
- Swift 5.9 或更高版本

### 开发流程

1. **克隆/进入项目目录**
2. **打开 Xcode 项目**
3. **配置签名**
4. **运行应用**
5. **测试功能**
6. **打包应用**

## 🔄 后续改进

### 功能增强

- [ ] 消息通知支持
- [ ] 多账号切换
- [ ] 聊天记录导出
- [ ] 快捷键支持
- [ ] 系统托盘集成

### 性能优化

- [ ] 实现本地缓存
- [ ] 优化 WebView 性能
- [ ] 减少内存占用

### 用户体验

- [ ] 暗黑模式完善
- [ ] 自定义主题
- [ ] 多语言支持
- [ ] 辅助功能支持

## 📞 获取帮助

如果遇到其他问题：

1. 查看 `TROUBLESHOOTING.md` 获取详细排查指南
2. 查看 `DEVELOPMENT_REPORT.md` 了解开发详情
3. 检查 Xcode 控制台错误信息
4. 查看 macOS 系统日志

## 📄 许可证

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🌟 贡献

Contributions are welcome! Please feel free to submit a Pull Request.

## 📅 版本历史

- **1.0.0** (2026-03-02): 初始版本
  - 完成 macOS 原生应用架构
  - 实现 WebView 嵌入登录功能
  - 实现聊天界面和状态管理
  - 创建完整的构建和测试脚本

## 📞 联系

- **Project Link**: [https://github.com/Elv1nx/ChatGPTMacOS](https://github.com/Elv1nx/ChatGPTMacOS)
- **Issues**: [https://github.com/Elv1nx/ChatGPTMacOS/issues](https://github.com/Elv1nx/ChatGPTMacOS/issues)

---

**最后更新**: 2026-03-03  
**版本**: 1.0.0  
**作者**: ElvinX
