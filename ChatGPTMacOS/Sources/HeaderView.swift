//
//  HeaderView.swift
//  ChatGPTMacOS
//
//  Created on 2026-03-02.
//  Copyright © 2026 ChatGPTMacOS. All rights reserved.
//

import SwiftUI

struct HeaderView: View {
    let onLogout: () -> Void
    
    var body: some View {
        HStack {
            Text("ChatGPT")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: onLogout) {
                Label("退出登录", systemImage: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 14, weight: .medium))
            }
            .buttonStyle(.bordered)
            .tint(.red)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(NSColor.separatorColor)),
            alignment: .bottom
        )
    }
}

#Preview {
    HeaderView(onLogout: {})
        .frame(width: 900, height: 60)
}
