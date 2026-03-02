//
//  InputView.swift
//  ChatGPTMacOS
//
//  Created on 2026-03-02.
//  Copyright © 2026 ChatGPTMacOS. All rights reserved.
//

import SwiftUI

struct InputView: View {
    @Binding var text: String
    let onSend: () -> Void
    let onNewConversation: () -> Void
    @FocusState private var isFocused: Bool
    @State private var isHovering = false
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 12) {
                // 新对话按钮
                Button(action: onNewConversation) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 36, height: 36)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .help("新对话")
                
                // 输入框
                ZStack(alignment: .topLeading) {
                    // 占位符
                    if text.isEmpty {
                        Text("输入消息... (Shift+Enter 换行)")
                            .font(.system(size: 15))
                            .foregroundColor(Color.gray.opacity(0.7))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                    }
                    
                    // 实际输入框
                    TextEditor(text: $text)
                        .font(.system(size: 15))
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                        .frame(minHeight: 44, maxHeight: 200)
                        .focused($isFocused)
                        .onChange(of: text) { _ in
                            // 自动调整高度（通过 TextEditor 自动处理）
                        }
                        .onSubmit {
                            // Enter 发送，Shift+Enter 换行
                            if !NSEvent.modifierFlags.contains(.shift) {
                                onSend()
                            }
                        }
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isFocused ? Color.blue : Color.gray.opacity(0.3), lineWidth: isFocused ? 2 : 1)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(NSColor.textBackgroundColor))
                        )
                )
                
                // 发送按钮
                Button(action: onSend) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty 
                                ? Color.gray 
                                : Color.blue
                        )
                        .cornerRadius(12)
                }
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .buttonStyle(.plain)
                .help("发送消息")
            }
            .padding(16)
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
}

#Preview {
    InputView(text: .constant(""), onSend: {}, onNewConversation: {})
        .frame(width: 600)
}
