//
//  ChatService.swift
//  ChatGPTMacOS
//
//  Created on 2026-03-02.
//  Copyright © 2026 ChatGPTMacOS. All rights reserved.
//

import Foundation
import Combine
import WebKit

@MainActor
    class ChatService: NSObject, ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var currentConversation: Conversation?
    @Published var isSending = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isStreaming = false
    
    private var webView: WKWebView?
    private var messageCompletionHandler: ((String) -> Void)?
    
    override init() {
        super.init()
        setupWebView()
    }
    
    private func setupWebView() {
        let configuration = WKWebViewConfiguration()
        
        // 设置浏览器偏好
        if #available(macOS 11.0, *) {
            configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            configuration.preferences.javaScriptEnabled = true
        }
        
        // 设置网站数据存储
        configuration.websiteDataStore = .default()
        
        // 设置自定义 User-Agent（模拟真实 Safari 浏览器）
        let userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"
        configuration.applicationNameForUserAgent = userAgent
        
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView?.isHidden = true
        
        // 设置自定义 HTTP 头部
        var request = URLRequest(url: URL(string: "https://chatgpt.com")!)
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("zh-CN,zh-Hans;q=0.9", forHTTPHeaderField: "Accept-Language")
        
        // 设置 WebView 代理
        let coordinator = WebViewCoordinator(service: self)
        webView?.navigationDelegate = coordinator
        webView?.uiDelegate = coordinator
        
        // 注入 JavaScript 监听器
        setupJavaScriptHandlers()
        
        // 加载 ChatGPT 页面
        webView?.load(request)
        
        print("🌐 WebView 初始化完成，User-Agent: \(userAgent)")
    }
    
    private func setupJavaScriptHandlers() {
        // 添加消息监听器
        guard let userContentController = webView?.configuration.userContentController else { return }
        userContentController.add(self, name: "messageObserver")
        userContentController.add(self, name: "streamObserver")
    }
    
    func sendMessage(_ content: String) async {
        print("📤 sendMessage 被调用，内容：\(content.prefix(50))")
        
        guard !content.trimmingCharacters(in: .whitespaces).isEmpty else { 
            print("❌ 消息内容为空")
            return 
        }
        guard webView != nil else {
            print("❌ WebView 未初始化")
            await MainActor.run {
                self.errorMessage = "WebView 未初始化"
            }
            return
        }
        
        // 检查 WebView 是否加载完成
        if webView?.url == nil {
            print("⏳ 等待 WebView 加载...")
            await MainActor.run {
                self.errorMessage = "正在加载 ChatGPT 页面，请稍候..."
            }
            return
        }
        
        print("✅ WebView 已就绪，URL: \(webView?.url?.absoluteString ?? "unknown")")
        
        await MainActor.run {
            self.isSending = true
            self.errorMessage = nil
            
            // 添加用户消息到当前会话
            let userMessage = Message(role: .user, content: content)
            print("💾 保存用户消息到会话")
            
            if var conversation = self.currentConversation {
                conversation.messages.append(userMessage)
                conversation.updatedAt = Date()
                
                // 如果是第一条消息，更新标题
                if conversation.messages.count == 1 {
                    conversation.title = String(content.prefix(30))
                }
                
                self.currentConversation = conversation
            } else {
                let newConversation = Conversation(
                    title: String(content.prefix(30)),
                    messages: [userMessage]
                )
                self.currentConversation = newConversation
                self.conversations.insert(newConversation, at: 0)
                print("🆕 创建新会话")
            }
        }
        
        // 模拟真实用户输入延迟（防检测）
        print("⏱️ 模拟用户输入延迟...")
        await simulateHumanDelay()
        
        // 通过 JavaScript 发送消息
        let js = createSendMessageJavaScript(content)
        print("📜 执行 JavaScript，长度：\(js.count)")
        await executeJavaScript(js)
        
        // 等待 AI 开始响应
        print("⏳ 等待 AI 响应...")
        await waitForAIResponse()
        
        print("✅ 消息发送完成")
        
        await MainActor.run {
            self.isSending = false
        }
    }
    
    /// 模拟真实用户行为延迟（防检测）
    private func simulateHumanDelay() async {
        // 随机延迟 200-800ms，模拟真实用户思考时间
        let delay = UInt64.random(in: 200_000_000...800_000_000)
        try? await Task.sleep(nanoseconds: delay)
    }
    
    /// 等待 AI 响应
    private func waitForAIResponse() async {
        await withCheckedContinuation { [weak self] continuation in
            self?.messageCompletionHandler = { response in
                Task { @MainActor [weak self] in
                    self?.handleAIResponse(response)
                    continuation.resume()
                }
            }
            
            // 设置超时（30 秒）
            Task {
                try? await Task.sleep(nanoseconds: 30_000_000_000)
                continuation.resume()
            }
        }
    }
    
    private func handleAIResponse(_ response: String) {
        guard var conversation = self.currentConversation else { return }
        
        // 检查最后一条消息是否是 AI 消息
        if let lastMessage = conversation.messages.last,
           lastMessage.role == .assistant,
           lastMessage.isLoading {
            // 更新现有消息
            conversation.messages[conversation.messages.count - 1].content = response
            conversation.messages[conversation.messages.count - 1].isLoading = false
        } else {
            // 添加新消息
            let aiMessage = Message(role: .assistant, content: response)
            conversation.messages.append(aiMessage)
        }
        
        conversation.updatedAt = Date()
        self.currentConversation = conversation
    }
    
    private func createSendMessageJavaScript(_ content: String) -> String {
        let escapedContent = content
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
        
        // 模拟真实用户输入过程（逐个字符输入）
        return """
        (function() {
            console.log('📤 ChatGPT macOS: 开始发送消息');
            
            // 尝试多种选择器找到文本框
            var textarea = document.querySelector('textarea');
            
            if (!textarea) {
                textarea = document.querySelector('[role="textbox"]');
            }
            
            if (textarea) {
                console.log('✅ ChatGPT macOS: 找到文本框');
                
                // 聚焦文本框
                textarea.focus();
                textarea.click();
                
                // 模拟真实输入过程
                var content = "\(escapedContent)";
                var index = 0;
                
                function typeCharacter() {
                    if (index < content.length) {
                        textarea.value += content.charAt(index);
                        textarea.dispatchEvent(new Event('input', { bubbles: true }));
                        index++;
                        // 随机打字速度（50-150ms 每字符）
                        setTimeout(typeCharacter, Math.random() * 100 + 50);
                    } else {
                        console.log('✅ ChatGPT macOS: 输入完成，准备发送');
                        
                        // 输入完成后发送
                        setTimeout(function() {
                            // 尝试多种选择器找到发送按钮
                            var sendButton = document.querySelector('button[type="submit"]');
                            
                            if (!sendButton) {
                                sendButton = document.querySelector('button[aria-label="Send message"]');
                            }
                            
                            if (sendButton && !sendButton.disabled) {
                                console.log('🚀 ChatGPT macOS: 点击发送按钮');
                                sendButton.click();
                            } else {
                                console.log('❌ ChatGPT macOS: 发送按钮不可用');
                            }
                        }, 300);
                    }
                }
                
                // 清空文本框并开始输入
                textarea.value = '';
                typeCharacter();
                return true;
            } else {
                console.log('❌ ChatGPT macOS: 未找到文本框');
                return false;
            }
        })();
        """
    }
    
    private func executeJavaScript(_ js: String) async {
        await MainActor.run {
            self.webView?.evaluateJavaScript(js) { _, error in
                if let error = error {
                    print("JavaScript execution error: \(error)")
                }
            }
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    func startNewConversation() {
        currentConversation = nil
    }
    
    func deleteConversation(_ conversation: Conversation) {
        conversations.removeAll { $0.id == conversation.id }
        if currentConversation?.id == conversation.id {
            currentConversation = nil
        }
    }
    
    func loadConversation(_ conversation: Conversation) {
        currentConversation = conversation
    }
    
    // 保存对话历史到本地
    func saveConversations() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let data = try encoder.encode(conversations)
            UserDefaults.standard.set(data, forKey: "savedConversations")
            print("💾 已保存 \(conversations.count) 个会话")
        } catch {
            print("❌ 保存会话失败：\(error)")
        }
    }
    
    // 从本地加载对话历史
    func loadSavedConversations() {
        guard let data = UserDefaults.standard.data(forKey: "savedConversations") else {
            return
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let saved = try decoder.decode([Conversation].self, from: data)
            conversations = saved
            print("📂 已加载 \(conversations.count) 个历史会话")
        } catch {
            print("❌ 加载会话失败：\(error)")
        }
    }
    
    func forceLogout() {
        // 重置应用状态
        conversations = []
        currentConversation = nil
        errorMessage = nil
        
        // 清除本地 Cookie（但服务器会话可能仍然有效）
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        print("强制登出执行")
    }
    
    func testWebView() async {
        print("🧪 ========== WebView 测试开始 ==========")
        print("🔍 WebView 状态：\(webView != nil ? "已初始化" : "未初始化")")
        print("🌐 WebView URL: \(webView?.url?.absoluteString ?? "nil")")
        print("📡 WebView 加载状态：\(webView?.isLoading ?? false ? "加载中" : "已加载")")
        
        if webView == nil {
            print("❌ WebView 未初始化！")
            return
        }
        
        if webView?.url == nil {
            print("❌ WebView 没有加载任何页面！")
            return
        }
        
        // 测试 JavaScript 执行
        let testJS = "document.title"
        print("📜 测试执行 JavaScript: \(testJS)")
        
        await MainActor.run {
            webView?.evaluateJavaScript(testJS) { result, error in
                if let error = error {
                    print("❌ JavaScript 执行失败：\(error)")
                } else if let title = result as? String {
                    print("✅ JavaScript 执行成功！页面标题：\(title)")
                }
            }
        }
        
        print("🧪 ========== WebView 测试结束 ==========")
    }
    
    deinit {
        Task { @MainActor in
            let userContentController = webView?.configuration.userContentController
            userContentController?.removeScriptMessageHandler(forName: "messageObserver")
            userContentController?.removeScriptMessageHandler(forName: "streamObserver")
        }
    }
}

// MARK: - WKScriptMessageHandler
extension ChatService: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "messageObserver":
            print("📥 收到消息回调")
            if let response = message.body as? String {
                print("📝 AI 回复内容长度：\(response.count)")
                messageCompletionHandler?(response)
            }
        case "streamObserver":
            // 处理流式输出
            if let chunk = message.body as? String {
                print("📊 收到流式数据：\(chunk.count) 字符")
                handleStreamingChunk(chunk)
            }
        default:
            break
        }
    }
    
    private func handleStreamingChunk(_ chunk: String) {
        // 处理流式数据块 - 实现打字机效果
        guard var conversation = self.currentConversation else { return }
        
        // 检查最后一条消息是否是 AI 消息
        if let lastMessage = conversation.messages.last,
           lastMessage.role == .assistant {
            // 更新现有消息的内容
            conversation.messages[conversation.messages.count - 1].content += chunk
            conversation.messages[conversation.messages.count - 1].isStreaming = true
        } else {
            // 添加新的流式消息
            let aiMessage = Message(role: .assistant, content: chunk, isStreaming: true)
            conversation.messages.append(aiMessage)
        }
        
        conversation.updatedAt = Date()
        self.currentConversation = conversation
    }
}

// MARK: - WebView Coordinator
extension ChatService {
    class WebViewCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        weak var service: ChatService?
        
        init(service: ChatService) {
            self.service = service
            super.init()
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // 注入监听 AI 响应的 JavaScript
            injectResponseObserver(webView: webView)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("❌ WebView 加载失败：\(error.localizedDescription)")
            
            // 检查是否是网络错误
            if let nsError = error as NSError? {
                switch nsError.code {
                case NSURLErrorNotConnectedToInternet:
                    print("🌐 网络连接失败，请检查网络")
                case NSURLErrorTimedOut:
                    print("⏰ 连接超时，请重试")
                case NSURLErrorCannotFindHost:
                    print("🔍 无法找到主机")
                default:
                    print("⚠️ 错误代码：\(nsError.code)")
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("❌ WebView 临时导航失败：\(error.localizedDescription)")
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, 
                    decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(.allow)
        }
        
        private func injectResponseObserver(webView: WKWebView) {
            let js = """
            (function() {
                console.log('🚀 ChatGPT macOS: 开始注入响应监听器');
                
                // 检查是否已经注入过
                if (window.chatGPTMacOSInjected) {
                    console.log('ℹ️ ChatGPT macOS: 监听器已存在，跳过注入');
                    return;
                }
                window.chatGPTMacOSInjected = true;
                
                // 监听 ChatGPT 的响应
                var lastContent = '';
                var streamInterval = null;
                var isWaitingForResponse = false;
                var responseCheckCount = 0;
                
                // 使用 MutationObserver 监听 DOM 变化
                var observer = new MutationObserver(function(mutations) {
                    // 尝试多种选择器查找 AI 回复
                    var responseDivs = null;
                    
                    // 选择器 1: data-message-author-role
                    responseDivs = document.querySelectorAll('[data-message-author-role="assistant"]');
                    
                    // 选择器 2: role="presentation"
                    if (responseDivs.length === 0) {
                        responseDivs = document.querySelectorAll('[role="presentation"]');
                    }
                    
                    // 选择器 3: 查找包含特定类名的 div
                    if (responseDivs.length === 0) {
                        responseDivs = document.querySelectorAll('div[class*="message"]');
                    }
                    
                    // 选择器 4: 通用方法 - 查找最后一个有大量文本的 div
                    if (responseDivs.length === 0) {
                        var allDivs = document.querySelectorAll('div');
                        var candidates = [];
                        for (var i = 0; i < allDivs.length; i++) {
                            var div = allDivs[i];
                            var text = div.textContent.trim();
                            if (text.length > 50 && text.length < 10000) {
                                candidates.push(div);
                            }
                        }
                        if (candidates.length > 0) {
                            responseDivs = [candidates[candidates.length - 1]];
                        }
                    }
                    
                    if (responseDivs && responseDivs.length > 0) {
                        responseCheckCount++;
                        var latestResponse = responseDivs[responseDivs.length - 1];
                        var currentContent = latestResponse.textContent.trim();
                        
                        console.log('📝 ChatGPT macOS: 检测到内容 (检查 #'+responseCheckCount+')，长度:', currentContent.length);
                        
                        if (currentContent && currentContent !== lastContent && currentContent.length > lastContent.length) {
                            isWaitingForResponse = true;
                            
                            // 发送增量内容
                            var newContent = currentContent.substring(lastContent.length);
                            console.log('📤 ChatGPT macOS: 发送流式数据块，长度:', newContent.length);
                            
                            if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.streamObserver) {
                                window.webkit.messageHandlers.streamObserver.postMessage(newContent);
                            }
                            
                            lastContent = currentContent;
                        }
                        
                        // 检测流式输出结束
                        if (streamInterval) {
                            clearInterval(streamInterval);
                        }
                        
                        streamInterval = setInterval(function() {
                            var sendButton = document.querySelector('button[type="submit"]');
                            if (sendButton && !sendButton.disabled && isWaitingForResponse) {
                                console.log('✅ ChatGPT macOS: AI 响应完成，发送完整内容，长度:', currentContent.length);
                                
                                if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.messageObserver) {
                                    window.webkit.messageHandlers.messageObserver.postMessage(currentContent);
                                }
                                
                                lastContent = '';
                                isWaitingForResponse = false;
                                clearInterval(streamInterval);
                                streamInterval = null;
                            }
                        }, 1000);
                    }
                });
                
                observer.observe(document.body, {
                    childList: true,
                    subtree: true,
                    characterData: true
                });
                
                console.log('✅ ChatGPT macOS: 响应监听器已激活，开始监听...');
            })();
            """
            
            webView.evaluateJavaScript(js) { _, error in
                if let error = error {
                    print("❌ 注入响应监听器失败：\(error)")
                } else {
                    print("✅ 注入响应监听器成功")
                }
            }
        }
    }
}
