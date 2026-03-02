//
//  MessageRowView.swift
//  ChatGPTMacOS
//
//  Created on 2026-03-02.
//  Copyright © 2026 ChatGPTMacOS. All rights reserved.
//

import SwiftUI

struct MessageRowView: View {
    let message: Message
    @State private var displayedContent = ""
    @State private var isTyping = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 头像
            Image(systemName: message.role.avatarName)
                .font(.system(size: 20))
                .foregroundColor(Color(message.role.avatarColor))
                .frame(width: 32, height: 32)
                .background(Color(message.role.avatarColor).opacity(0.1))
                .cornerRadius(8)
            
            // 消息内容
            VStack(alignment: .leading, spacing: 6) {
                // 发送者名称和时间
                HStack {
                    Text(message.role.displayName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    Text(formatDate(message.timestamp))
                        .font(.system(size: 11))
                        .foregroundColor(Color.gray.opacity(0.7))
                }
                
                // 消息内容
                if message.isLoading {
                    // 加载状态
                    HStack(spacing: 6) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("正在思考...")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                } else if message.isStreaming {
                    // 流式输出中 - 使用打字机效果
                    typingTextView
                    
                    // 流式光标动画
                    HStack(spacing: 6) {
                        Rectangle()
                            .fill(Color.secondary)
                            .frame(width: 2, height: 14)
                            .animation(.easeInOut(duration: 0.6).repeatForever(), value: UUID())
                        Text("正在输入...")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                    .onAppear {
                        startTypingEffect()
                    }
                    .onChange(of: message.content) {
                        startTypingEffect()
                    }
                } else {
                    // 完整消息 - 使用 Markdown 渲染
                    MarkdownText(text: message.content)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(message.role == .user ? Color.green.opacity(0.05) : Color.blue.opacity(0.05))
        )
    }
    
    @ViewBuilder
    private var typingTextView: some View {
        if isTyping {
            // 打字机效果
            Text(displayedContent)
                .font(.system(size: 15))
                .textSelection(.enabled)
                .lineSpacing(4)
        } else {
            // 打字完成，显示完整内容
            Text(message.content)
                .font(.system(size: 15))
                .textSelection(.enabled)
                .lineSpacing(4)
        }
    }
    
    private func startTypingEffect() {
        guard !message.content.isEmpty && message.isStreaming else {
            displayedContent = message.content
            isTyping = false
            return
        }
        
        isTyping = true
        displayedContent = ""
        
        let typingSpeed = 0.02 // 每字符 20ms
        var currentIndex = 0
        let content = message.content
        
        Timer.scheduledTimer(withTimeInterval: typingSpeed, repeats: true) { timer in
            if currentIndex < content.count {
                let index = content.index(content.startIndex, offsetBy: currentIndex)
                displayedContent.append(content[index])
                currentIndex += 1
            } else {
                timer.invalidate()
                isTyping = false
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    VStack(spacing: 16) {
        MessageRowView(message: Message(role: .user, content: "你好，请帮我写一个 Swift 函数"))
        MessageRowView(message: Message(role: .assistant, content: "当然可以！以下是一个简单的 Swift 函数示例"))
        MessageRowView(message: Message(role: .assistant, content: "", isLoading: true))
        MessageRowView(message: Message(role: .assistant, content: "这是一个测试", isStreaming: true))
    }
    .padding()
    .frame(width: 600)
}
