//
//  LoginView.swift
//  ChatGPTMacOS
//  性能优化版本
//
//  Created on 2026-03-02.
//  Copyright © 2026 ChatGPTMacOS. All rights reserved.
//

import SwiftUI
import WebKit

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var webViewOpacity = 0.0
    
    var body: some View {
        ZStack {
            // 背景
            Color(NSColor.windowBackgroundColor)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // 始终显示主内容（包含 WebView）
                mainContent
                    .opacity(webViewOpacity)
                    .animation(.easeInOut(duration: 0.3), value: webViewOpacity)
                
                // 错误信息
                if let error = appState.errorMessage {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 24))
                            .foregroundColor(.red)
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding(40)
            
            // 加载指示器覆盖层
            if appState.isLoading || webViewOpacity < 1.0 {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("正在加载登录页面...")
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                }
                .padding(30)
                .background(Color(NSColor.windowBackgroundColor))
                .cornerRadius(12)
                .shadow(radius: 10)
            }
        }
        .onAppear {
            // WebView 加载完成后淡入显示
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    webViewOpacity = 1.0
                }
            }
        }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        VStack(spacing: 20) {
            // 标题
            VStack(spacing: 8) {
                Text("ChatGPT macOS")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("使用您的 OpenAI 账号登录")
                    .font(.system(size: 18))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // WebView 容器
            WebViewContainer(isLoginMode: true)
                .frame(minWidth: 600, minHeight: 500)
                .cornerRadius(12)
                .shadow(radius: 10)
            
            // 添加一个提示按钮，如果检测到已登录
            if let url = appState.currentURL,
               url.host?.contains("chatgpt.com") == true,
               !url.absoluteString.contains("/auth/"),
               !url.absoluteString.contains("/login") {
                VStack(spacing: 12) {
                    Text("✅ 检测到已登录账户")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        appState.handleLoginSuccess()
                    }) {
                        Text("使用当前账户")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 8)
                }
                .padding()
                .background(Color(NSColor.systemGreen).opacity(0.1))
                .cornerRadius(10)
            }
            
            Spacer()
            
            // 错误信息
            if let error = appState.errorMessage {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 24))
                        .foregroundColor(.red)
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AppState())
        .frame(width: 900, height: 600)
}
