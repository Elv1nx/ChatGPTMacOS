//
//  Conversation.swift
//  ChatGPTMacOS
//
//  Created on 2026-03-02.
//  Copyright © 2026 ChatGPTMacOS. All rights reserved.
//

import Foundation

struct Conversation: Identifiable, Codable {
    let id: String
    var title: String
    var messages: [Message]
    var updatedAt: Date
    
    init(
        id: String = UUID().uuidString,
        title: String = "新对话",
        messages: [Message] = [],
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.messages = messages
        self.updatedAt = updatedAt
    }
    
    var preview: String {
        guard let lastMessage = messages.last else {
            return "新对话"
        }
        return String(lastMessage.content.prefix(50))
    }
    
    var messageCount: Int {
        messages.count
    }
}
