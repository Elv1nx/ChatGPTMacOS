# ChatGPT macOS 开发问题排查指南

## 常见问题及解决方案

### 1. 构建失败

#### 问题：Xcode 编译错误
```
error: Build input file cannot be found
```

**解决方案：**
```bash
# 清理 DerivedData
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# 清理项目
xcodebuild clean -project ChatGPTMacOS.xcodeproj -scheme ChatGPTMacOS

# 重新打开 Xcode
open ChatGPTMacOS.xcodeproj
```

#### 问题：Swift 版本不兼容
```
error: Swift compiler language version compatibility
```

**解决方案：**
- 在 Xcode 中检查 Build Settings > Swift Compiler - Language > Swift Language Version
- 确保设置为 Swift 5

### 2. WebView 加载问题

#### 问题：页面无法加载
```
Error Domain=NSURLErrorDomain Code=-1003
```

**解决方案：**
1. 检查网络连接
2. 确认 Info.plist 中配置了 ATS 权限
3. 检查 Entitlements.plist 配置

#### 问题：Cookie 无法保存
**解决方案：**
```swift
// 使用 WKWebsiteDataStore 的默认配置
let configuration = WKWebViewConfiguration()
configuration.websiteDataStore = .default()
```

### 3. 登录状态检测

#### 问题：无法检测登录状态
**解决方案：**
- 检查 URL 变化监听
- 使用 JavaScript 注入检测页面元素
- 监听特定 Cookie 的存在

```swift
// 在 WebView 中执行 JavaScript
webView.evaluateJavaScript("document.title") { result, error in
    if let title = result as? String {
        print("页面标题：\(title)")
    }
}
```

### 4. 应用签名问题

#### 问题：应用无法打开（损坏的应用）
```
"ChatGPT.app" is damaged and can't be opened
```

**解决方案：**
```bash
# 移除隔离属性
xattr -cr /path/to/ChatGPT.app

# 重新签名
codesign --force --deep --sign - /path/to/ChatGPT.app
```

#### 问题：开发者证书问题
**解决方案：**
```bash
# 查看可用证书
security find-identity -v -p codesigning

# 使用开发证书签名
codesign --force --deep --sign "Your Certificate Name" ChatGPT.app
```

### 5. 性能问题

#### 问题：应用响应慢
**解决方案：**
1. 启用 Metal 性能 HUD 检查渲染性能
2. 减少不必要的视图刷新
3. 优化 WebView 配置

```swift
// 优化 WebView 性能
configuration.preferences.javaScriptCanOpenWindowsAutomatically = false
configuration.preferences.isElementFullscreenEnabled = true
```

#### 问题：内存占用高
**解决方案：**
- 定期清理 WebView 缓存
- 使用 Instruments 工具分析内存泄漏

### 6. UI 问题

#### 问题：窗口大小不正确
**解决方案：**
```swift
// 在 ContentView 中设置最小尺寸
.frame(minWidth: 900, minHeight: 600)
```

#### 问题：暗黑模式适配
**解决方案：**
- 使用 NSColor 系统颜色
- 避免硬编码颜色值
- 使用 SwiftUI 的自适应颜色

### 7. 网络问题

#### 问题：无法访问 ChatGPT
**解决方案：**
1. 检查网络代理设置
2. 确认 DNS 配置
3. 尝试使用不同的网络环境

```bash
# 清除 DNS 缓存
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
```

### 8. 调试技巧

#### 启用详细日志
```bash
# 设置环境变量
export OS_ACTIVITY_MODE=enable

# 运行应用
open ChatGPT.app --args -NSDebugLoud
```

#### 使用 Console.app 查看日志
```bash
# 过滤应用日志
log show --predicate 'process == "ChatGPT"' --last 1h
```

### 9. 打包问题

#### 问题：导出失败
```
error: exportArchive: No export allowed
```

**解决方案：**
- 检查 ExportOptions.plist 配置
- 确保使用正确的签名证书
- 验证项目配置

### 10. 其他工具

#### 查看应用信息
```bash
# 查看应用架构
lipo -info ChatGPT.app/Contents/MacOS/ChatGPT

# 查看签名信息
codesign -dv --verbose=4 ChatGPT.app

# 查看 entitlements
codesign -d --entitlements :- ChatGPT.app
```

#### 性能分析
```bash
# 使用 Instruments
open -a Instruments

# 分析应用启动时间
time open ChatGPT.app
```

## 联系支持

如果以上方法无法解决问题，请：
1. 查看 Xcode 控制台完整错误信息
2. 检查 macOS 系统日志
3. 搜索 Apple Developer 论坛
4. 查阅 SwiftUI 和 WebKit 文档
