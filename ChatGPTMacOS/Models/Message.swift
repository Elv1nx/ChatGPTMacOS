//
//  Message.swift
//  ChatGPTMacOS
//
//  Created on 2026-03-02.
//  Copyright © 2026 ChatGPTMacOS. All rights reserved.
//

import Foundation

struct Message: Identifiable, Codable, Equatable {
    let id: String
    let role: MessageRole
    var content: String
    let timestamp: Date
    var isStreaming: Bool
    var isLoading: Bool
    
    init(
        id: String = UUID().uuidString,
        role: MessageRole,
        content: String,
        timestamp: Date = Date(),
        isStreaming: Bool = false,
        isLoading: Bool = false
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
        self.isStreaming = isStreaming
        self.isLoading = isLoading
    }
    
    enum MessageRole: String, Codable, Equatable {
        case user
        case assistant
        case system
        
        var displayName: String {
            switch self {
            case .user: return "您"
            case .assistant: return "ChatGPT"
            case .system: return "系统"
            }
        }
        
        var avatarName: String {
            switch self {
            case .user: return "person.circle.fill"
            case .assistant: return "cpu"
            case .system: return "gearshape.fill"
            }
        }
        
        var avatarColor: String {
            switch self {
            case .user: return "green"
            case .assistant: return "blue"
            case .system: return "orange"
            }
        }
    }
}
