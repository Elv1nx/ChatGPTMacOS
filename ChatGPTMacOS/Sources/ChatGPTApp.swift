//
//  ChatGPTApp.swift
//  ChatGPTMacOS
//
//  Created on 2026-03-02.
//  Copyright © 2026 ChatGPTMacOS. All rights reserved.
//

import SwiftUI

@main
struct ChatGPTApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .frame(minWidth: 900, minHeight: 600)
                .onAppear {
                    // 应用启动时强制登出，确保显示登录界面
                    appState.forceLogout()
                }
        }
        .windowStyle(.titleBar)
        .commands {
            CommandGroup(replacing: .newItem) {}
            
            // 添加设置菜单
            CommandGroup(after: .appSettings) {
                Divider()
            }
        }
        
        // 设置窗口
        Settings {
            SettingsView()
        }
    }
}
