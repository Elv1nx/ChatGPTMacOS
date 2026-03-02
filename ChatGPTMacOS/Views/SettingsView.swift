//
//  SettingsView.swift
//  ChatGPTMacOS
//
//  Created on 2026-03-02.
//  Copyright © 2026 ChatGPTMacOS. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("typingSpeed") private var typingSpeed: Double = 0.02
    @AppStorage("enableTypingEffect") private var enableTypingEffect: Bool = true
    @AppStorage("enableMarkdown") private var enableMarkdown: Bool = true
    @AppStorage("theme") private var theme: String = "system"
    
    var body: some View {
        Form {
            // 打字机效果设置
            Section("打字机效果") {
                Toggle("启用打字机效果", isOn: $enableTypingEffect)
                
                if enableTypingEffect {
                    VStack(alignment: .leading) {
                        Text("打字速度：\(typingSpeed, specifier: "%.2f")秒/字符")
                        Slider(value: $typingSpeed, in: 0.01...0.1, step: 0.01)
                    }
                }
            }
            
            // 渲染设置
            Section("渲染") {
                Toggle("启用 Markdown 渲染", isOn: $enableMarkdown)
            }
            
            // 主题设置
            Section("外观") {
                Picker("主题", selection: $theme) {
                    Text("跟随系统").tag("system")
                    Text("浅色").tag("light")
                    Text("深色").tag("dark")
                }
                .pickerStyle(.radioGroup)
            }
            
            // 关于
            Section("关于") {
                HStack {
                    Text("版本")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("构建日期")
                    Spacer()
                    Text("2026-03-02")
                        .foregroundColor(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 450, height: 300)
    }
}

#Preview {
    SettingsView()
}
