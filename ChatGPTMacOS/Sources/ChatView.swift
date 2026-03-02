//
//  ChatView.swift
//  ChatGPTMacOS
//
//  Created on 2026-03-02.
//  Copyright © 2026 ChatGPTMacOS. All rights reserved.
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingLogoutAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(onLogout: { showingLogoutAlert = true })
            
            WebViewContainer(isLoginMode: false)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .alert("确认退出", isPresented: $showingLogoutAlert) {
            Button("取消", role: .cancel) {}
            Button("退出", role: .destructive) {
                appState.logout()
            }
        } message: {
            Text("确定要退出登录吗？")
        }
    }
}

#Preview {
    ChatView()
        .environmentObject(AppState())
        .frame(width: 900, height: 600)
}
