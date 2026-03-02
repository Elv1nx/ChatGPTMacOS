//
//  NativeChatView.swift
//  ChatGPTMacOS
//
//  Created on 2026-03-02.
//  Copyright © 2026 ChatGPTMacOS. All rights reserved.
//

import SwiftUI

struct NativeChatView: View {
    @StateObject private var chatService = ChatService()
    @State private var messageText = ""
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部标题栏
            headerView
            
            Divider()
            
            // 消息列表
            if chatService.currentConversation != nil {
                MessageListView(chatService: chatService)
            } else {
                emptyStateView
            }
            
            // 错误提示
            if let error = chatService.errorMessage {
                errorBanner(error: error)
            }
            
            // 输入框
            InputView(
                text: $messageText,
                onSend: sendMessage,
                onNewConversation: startNewConversation
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("ChatGPT")
                    .font(.system(size: 18, weight: .semibold))
                if let conversation = chatService.currentConversation {
                    Text(conversation.title)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // 测试按钮
            Button(action: testConnection) {
                Label("测试", systemImage: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 13, weight: .medium))
            }
            .buttonStyle(.bordered)
            .help("测试 WebView 连接")
            
            // 新对话按钮
            Button(action: startNewConversation) {
                Label("新对话", systemImage: "plus")
                    .font(.system(size: 13, weight: .medium))
            }
            .buttonStyle(.bordered)
            
            // 刷新按钮
            Button(action: {
                // 刷新当前对话
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 14))
            }
            .buttonStyle(.bordered)
            
            // 退出登录按钮
            Button(action: handleLogout) {
                Label("退出", systemImage: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 13, weight: .medium))
            }
            .buttonStyle(.bordered)
            .tint(.red)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "message.fill")
                .font(.system(size: 64))
                .foregroundColor(.blue.opacity(0.5))
            
            Text("开始新的对话")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("在下方输入框中输入消息，开始与 ChatGPT 对话")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorBanner(error: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(error)
                .font(.system(size: 13))
                .foregroundColor(.red)
            
            Spacer()
            
            Button(action: { chatService.clearError() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 12))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal, 16)
    }
    
    // MARK: - Actions
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let content = messageText
        messageText = ""
        
        Task {
            await chatService.sendMessage(content)
        }
    }
    
    private func startNewConversation() {
        chatService.startNewConversation()
        messageText = ""
        chatService.clearError()
    }
    
    private func handleLogout() {
        // 重置应用状态
        appState.forceLogout()
        chatService.startNewConversation()
        messageText = ""
        
        // 注意：由于 ChatGPT 服务器端会话不会立即过期，
        // 退出登录后可能仍会自动登录。这是正常行为。
        // 如需完全退出，请在 ChatGPT 网页中手动退出。
    }
    
    private func testConnection() {
        // 测试 WebView 连接
        Task {
            await chatService.testWebView()
        }
    }
}

#Preview {
    NativeChatView()
        .environmentObject(AppState())
        .frame(width: 900, height: 600)
}
