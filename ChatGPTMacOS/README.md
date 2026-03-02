# ChatGPT macOS 快速开始指南

## 🚀 快速开始（3 分钟上手）

### 方法一：使用 Xcode（推荐）

**步骤 1: 打开项目**
```bash
cd /Users/elvinx/chatgpt-cn/ChatGPTMacOS
open ChatGPTMacOS.xcodeproj
```

**步骤 2: 在 Xcode 中运行**
1. 等待 Xcode 索引完成
2. 确保顶部选择 `ChatGPTMacOS` Scheme
3. 点击运行按钮 (▶️) 或按 `⌘R`
4. 应用启动后，在登录页面输入 OpenAI 账号密码

**步骤 3: 开始聊天**
- 登录成功后自动进入聊天界面
- 可以直接在嵌入的网页中聊天

---

### 方法二：命令行构建

**构建并运行**:
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

# 构建成功后，应用位于:
# ~/Library/Developer/Xcode/DerivedData/ChatGPTMacOS-*/Build/Products/Debug/ChatGPT.app
```

**运行应用**:
```bash
open ~/Library/Developer/Xcode/DerivedData/ChatGPTMacOS-*/Build/Products/Debug/ChatGPT.app
```

---

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

---

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

---

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

---

## 🎯 性能优化

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

---

## 📚 文件说明

```
ChatGPTMacOS/
├── Sources/                    # 源代码
│   ├── ChatGPTApp.swift        # 应用入口
│   ├── AppState.swift          # 状态管理
│   ├── ContentView.swift       # 主视图
│   ├── LoginView.swift         # 登录页面
│   ├── ChatView.swift          # 聊天页面
│   ├── HeaderView.swift        # 头部栏
│   └── WebViewContainer.swift  # WebView 容器
├── Resources/                  # 配置文件
│   ├── Info.plist              # 应用信息
│   ├── Entitlements.plist      # 权限配置
│   └── ExportOptions.plist     # 导出配置
├── build.sh                    # 打包脚本
├── test.sh                     # 测试脚本
├── TROUBLESHOOTING.md          # 问题排查
└── DEVELOPMENT_REPORT.md       # 开发报告
```

---

## 🔐 安全提示

- ⚠️ 不要在公共电脑上使用
- ⚠️ 定期更改密码
- ⚠️ 退出时确认清除会话
- ✅ 应用不会存储你的密码
- ✅ 所有数据都存储在本地

---

## 📞 获取帮助

如果遇到其他问题：

1. 查看 `TROUBLESHOOTING.md` 获取详细排查指南
2. 查看 `DEVELOPMENT_REPORT.md` 了解开发详情
3. 检查 Xcode 控制台错误信息
4. 查看 macOS 系统日志

---

**最后更新**: 2026-03-02  
**版本**: 1.0.0
