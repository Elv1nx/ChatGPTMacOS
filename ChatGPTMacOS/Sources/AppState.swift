//
//  AppState.swift
//  ChatGPTMacOS
//
//  Created on 2026-03-02.
//  Copyright © 2026 ChatGPTMacOS. All rights reserved.
//

import Foundation
import Combine
import WebKit

class AppState: ObservableObject {
    @Published var isLoggedIn = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentURL: URL?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // 确保初始化时登录状态为 false
        isLoggedIn = false
        isLoading = true  // 初始状态为加载中
        print("AppState 初始化，isLoggedIn = \(isLoggedIn)")
    }
    
    func checkLoginStatus() {
        isLoggedIn = currentURL?.host?.contains("chatgpt.com") ?? false
    }
    
    func login() {
        isLoading = true
        errorMessage = nil
    }
    
    func logout() {
        isLoggedIn = false
        currentURL = nil
        print("用户已登出")
    }
    
    func forceLogout() {
        // 强制登出，用于测试
        isLoggedIn = false
        currentURL = nil
        errorMessage = nil
        
        // 清除所有 Cookie 和网站数据
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: Date.distantPast, completionHandler: {
            print("WebView 数据已清除")
        })
        
        print("强制登出执行")
    }
    
    func handleLoginSuccess() {
        DispatchQueue.main.async {
            self.isLoggedIn = true
            self.isLoading = false
            self.errorMessage = nil
            print("登录成功，isLoggedIn = \(self.isLoggedIn)")
        }
    }
    
    func handleLoginError(_ message: String) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.errorMessage = message
        }
    }
}
