//
//  MarkdownText.swift
//  ChatGPTMacOS
//
//  Created on 2026-03-02.
//  Copyright © 2026 ChatGPTMacOS. All rights reserved.
//

import SwiftUI

struct MarkdownText: View {
    let text: String
    
    var body: some View {
        ScrollView {
            let blocks = parseMarkdown(text)
            VStack(alignment: .leading, spacing: 12) {
                ForEach(0..<blocks.count, id: \.self) { index in
                    renderBlock(blocks[index])
                }
            }
            .textSelection(.enabled)
        }
    }
    
    private func parseMarkdown(_ text: String) -> [MarkdownBlock] {
        var blocks: [MarkdownBlock] = []
        let lines = text.components(separatedBy: "\n")
        var currentParagraph: [String] = []
        var inCodeBlock = false
        var codeBlockContent: [String] = []
        var codeBlockLanguage: String = ""
        
        var i = 0
        while i < lines.count {
            let line = lines[i]
            
            // 代码块
            if line.trimmingCharacters(in: .whitespaces).starts(with: "```") {
                if !inCodeBlock {
                    // 开始代码块
                    inCodeBlock = true
                    codeBlockLanguage = String(line.trimmingCharacters(in: .whitespaces).dropFirst(3))
                    codeBlockContent = []
                } else {
                    // 结束代码块
                    inCodeBlock = false
                    blocks.append(.codeBlock(language: codeBlockLanguage, code: codeBlockContent.joined(separator: "\n")))
                    codeBlockContent = []
                    codeBlockLanguage = ""
                }
                i += 1
                continue
            }
            
            if inCodeBlock {
                codeBlockContent.append(line)
                i += 1
                continue
            }
            
            // 标题
            if line.starts(with: "# ") {
                if !currentParagraph.isEmpty {
                    blocks.append(.paragraph(currentParagraph.joined(separator: "\n")))
                    currentParagraph = []
                }
                blocks.append(.heading(level: 1, text: String(line.dropFirst(2))))
                i += 1
                continue
            }
            
            if line.starts(with: "## ") {
                if !currentParagraph.isEmpty {
                    blocks.append(.paragraph(currentParagraph.joined(separator: "\n")))
                    currentParagraph = []
                }
                blocks.append(.heading(level: 2, text: String(line.dropFirst(3))))
                i += 1
                continue
            }
            
            if line.starts(with: "### ") {
                if !currentParagraph.isEmpty {
                    blocks.append(.paragraph(currentParagraph.joined(separator: "\n")))
                    currentParagraph = []
                }
                blocks.append(.heading(level: 3, text: String(line.dropFirst(4))))
                i += 1
                continue
            }
            
            // 列表项
            if line.trimmingCharacters(in: .whitespaces).starts(with: "- ") ||
               line.trimmingCharacters(in: .whitespaces).starts(with: "* ") ||
               line.trimmingCharacters(in: .whitespaces).starts(with: "+ ") {
                if !currentParagraph.isEmpty {
                    blocks.append(.paragraph(currentParagraph.joined(separator: "\n")))
                    currentParagraph = []
                }
                let itemText = String(line.trimmingCharacters(in: .whitespaces).dropFirst(2))
                blocks.append(.listItem(text: itemText))
                i += 1
                continue
            }
            
            // 有序列表
            if line.range(of: #"^\d+\.\s"#, options: .regularExpression) != nil {
                if !currentParagraph.isEmpty {
                    blocks.append(.paragraph(currentParagraph.joined(separator: "\n")))
                    currentParagraph = []
                }
                // 找到第一个点和空格的位置
                if let dotRange = line.range(of: ".") {
                    let itemText = String(line[dotRange.upperBound...]).trimmingCharacters(in: .whitespaces)
                    blocks.append(.orderedListItem(text: itemText))
                }
                i += 1
                continue
            }
            
            // 空行
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                if !currentParagraph.isEmpty {
                    blocks.append(.paragraph(currentParagraph.joined(separator: "\n")))
                    currentParagraph = []
                }
                i += 1
                continue
            }
            
            // 普通段落
            currentParagraph.append(line)
            i += 1
        }
        
        // 处理剩余的段落
        if !currentParagraph.isEmpty {
            blocks.append(.paragraph(currentParagraph.joined(separator: "\n")))
        }
        
        return blocks
    }
    
    @ViewBuilder
    private func renderBlock(_ block: MarkdownBlock) -> some View {
        switch block {
        case .paragraph(let text):
            applyInlineFormatting(text)
                .font(.system(size: 15))
                .lineSpacing(4)
            
        case .heading(let level, let text):
            Text(text)
                .font(.system(size: CGFloat(28 - level * 4), weight: .bold))
                .padding(.top, level == 1 ? 20 : 12)
                .padding(.bottom, 8)
            
        case .listItem(let text):
            HStack(alignment: .top, spacing: 8) {
                Text("•")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                applyInlineFormatting(text)
                    .font(.system(size: 15))
            }
            .padding(.leading, 20)
            
        case .orderedListItem(let text):
            HStack(alignment: .top, spacing: 8) {
                Text("1.")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                applyInlineFormatting(text)
                    .font(.system(size: 15))
            }
            .padding(.leading, 20)
            
        case .codeBlock(let language, let code):
            HighlightedCodeBlockView(language: language, code: code)
        }
    }
    
    private func applyInlineFormatting(_ text: String) -> Text {
        // 简单的内联格式化（粗体、斜体、行内代码）
        var result = Text(text)
        
        // 粗体 **text**
        if let range = text.range(of: #"\*\*([^*]+)\*\*"#, options: .regularExpression) {
            let match = String(text[range])
            let boldText = String(match.dropFirst(2).dropLast(2))
            let prefix = text.replacingOccurrences(of: match, with: "")
            result = Text(prefix) + Text(boldText).bold()
        }
        
        // 行内代码 `code`
        if let range = text.range(of: #"`([^`]+)`"#, options: .regularExpression) {
            let match = String(text[range])
            let codeText = String(match.dropFirst().dropLast())
            let prefix = text.replacingOccurrences(of: match, with: "")
            result = Text(prefix) +
                     Text(codeText)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.orange)
        }
        
        return result
    }
}

enum MarkdownBlock {
    case paragraph(String)
    case heading(level: Int, text: String)
    case listItem(text: String)
    case orderedListItem(text: String)
    case codeBlock(language: String, code: String)
}

struct CodeBlockView: View {
    let language: String
    let code: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 语言标签
            if !language.isEmpty {
                Text(language.uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
            }
            
            // 代码内容
            ScrollView(.horizontal, showsIndicators: true) {
                Text(code)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.primary)
                    .textSelection(.enabled)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color(NSColor.textBackgroundColor).opacity(0.5))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ScrollView {
        VStack(alignment: .leading, spacing: 16) {
            MarkdownText(text: """
# 标题 1

## 标题 2

这是一个**粗体**文本和 `行内代码` 的示例。

### 代码示例

```swift
func greet(name: String) -> String {
    return "Hello, \\(name)!"
}
```

### 列表

- 列表项 1
- 列表项 2
- 列表项 3

1. 有序列表 1
2. 有序列表 2

普通段落文本。
""")
        }
        .padding()
    }
    .frame(width: 600, height: 500)
}
