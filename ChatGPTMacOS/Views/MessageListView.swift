//
//  MessageListView.swift
//  ChatGPTMacOS
//
//  Created on 2026-03-02.
//  Copyright © 2026 ChatGPTMacOS. All rights reserved.
//

import SwiftUI

struct MessageListView: View {
    @ObservedObject var chatService: ChatService
    @Namespace private var scrollSpace
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(chatService.currentConversation?.messages ?? []) { message in
                        MessageRowView(message: message)
                            .id(message.id)
                    }
                }
                .padding(.vertical, 16)
                
                // 自动滚动标记
                Spacer()
                    .id("bottom")
            }
            .onChange(of: chatService.currentConversation?.messages.count) { _ in
                // 新消息时自动滚动到底部
                withAnimation {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
            .onChange(of: chatService.isSending) { _ in
                // 发送消息时自动滚动到底部
                withAnimation {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
        }
    }
}

#Preview {
    MessageListView(chatService: ChatService())
        .frame(width: 600, height: 400)
}
