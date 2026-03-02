//
//  WebViewContainer.swift
//  ChatGPTMacOS
//  性能优化版本
//
//  Created on 2026-03-02.
//  Copyright © 2026 ChatGPTMacOS. All rights reserved.
//

import SwiftUI
import WebKit

struct WebViewContainer: NSViewRepresentable {
    let isLoginMode: Bool
    @EnvironmentObject var appState: AppState
    
    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        
        // 性能优化配置
        configuration.preferences.isElementFullscreenEnabled = true
        configuration.suppressesIncrementalRendering = true  // 减少渐进渲染
        configuration.allowsAirPlayForMediaPlayback = false // 禁用 AirPlay 提高性能
        
        if #available(macOS 14.0, *) {
            configuration.allowsInlinePredictions = true
        }
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = false  // 禁用链接预览提高性能
        
        // 启用硬件加速
        webView.wantsLayer = true
        if let layer = webView.layer {
            layer.contentsScale = NSScreen.main?.backingScaleFactor ?? 2.0
        }
        
        // 设置背景色（使用 layer 方式兼容 macOS 13.0+）
        webView.wantsLayer = true
        webView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        webView.setValue(true, forKey: "drawsBackground")
        
        if isLoginMode {
            let loginURL = URL(string: "https://chatgpt.com")!
            let request = URLRequest(url: loginURL)
            webView.load(request)
        } else {
            if let url = appState.currentURL {
                let request = URLRequest(url: url)
                webView.load(request)
            } else {
                let chatURL = URL(string: "https://chatgpt.com")!
                let request = URLRequest(url: chatURL)
                webView.load(request)
            }
        }
        
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        // 避免不必要的更新以提高性能
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WebViewContainer
        
        init(_ parent: WebViewContainer) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("✅ WebView 页面加载完成：\(webView.url?.absoluteString ?? "unknown")")
            
            // WebView 加载完成，隐藏加载状态
            parent.appState.isLoading = false
            
            if let url = webView.url {
                parent.appState.currentURL = url
                
                if parent.isLoginMode {
                    print("📍 当前处于登录模式")
                    
                    // 检查是否已经登录（即不在登录页面上）
                    let isOnLoginPage = url.absoluteString.contains("/auth/") || 
                                       url.absoluteString.contains("/login") ||
                                       url.absoluteString.contains("/signup")
                    
                    // 只在非登录页面且 URL 包含 chatgpt.com 时才视为已登录
                    if url.host?.contains("chatgpt.com") == true && !isOnLoginPage {
                        print("🎯 检测到已登录账户，等待用户确认")
                        // 不自动跳转，让用户手动选择
                        // parent.appState.handleLoginSuccess()
                    } else if isOnLoginPage {
                        print("📝 当前在登录页面")
                    }
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("❌ WebView 加载失败：\(error.localizedDescription)")
            
            // 显示错误信息
            parent.appState.handleLoginError("无法连接到 ChatGPT 服务器：\(error.localizedDescription)\n\n请检查网络连接后重试。")
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("❌ WebView 临时导航失败：\(error.localizedDescription)")
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, 
                    decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(.allow)
        }
        
        // 处理新窗口请求
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }
    }
}
