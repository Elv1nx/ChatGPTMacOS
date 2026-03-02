//
//  CodeHighlighter.swift
//  ChatGPTMacOS
//
//  Created on 2026-03-02.
//  Copyright © 2026 ChatGPTMacOS. All rights reserved.
//

import SwiftUI

struct CodeHighlighter {
    
    // 常见编程语言的关键词
    static let keywords: [String: [String]] = [
        "swift": ["func", "var", "let", "class", "struct", "enum", "protocol", "extension", "if", "else", "for", "while", "return", "import", "public", "private", "internal", "fileprivate", "static", "dynamic", "final", "override", "convenience", "required", "lazy", "weak", "unowned", "guard", "defer", "throw", "throws", "rethrows", "try", "catch", "do", "where", "associatedtype", "default", "inout", "some", "any", "self", "Self", "Type", "Protocol"],
        "python": ["def", "class", "if", "elif", "else", "for", "while", "return", "import", "from", "as", "try", "except", "finally", "raise", "with", "lambda", "yield", "global", "nonlocal", "assert", "pass", "break", "continue", "in", "is", "not", "and", "or", "True", "False", "None"],
        "javascript": ["function", "var", "let", "const", "class", "if", "else", "for", "while", "return", "import", "export", "default", "try", "catch", "finally", "throw", "new", "this", "super", "extends", "async", "await", "yield", "typeof", "instanceof", "in", "of", "true", "false", "null", "undefined"],
        "java": ["public", "private", "protected", "class", "interface", "extends", "implements", "if", "else", "for", "while", "return", "import", "package", "try", "catch", "finally", "throw", "throws", "new", "this", "super", "static", "final", "abstract", "synchronized", "volatile", "transient", "native", "strictfp", "void", "boolean", "byte", "char", "short", "int", "long", "float", "double"],
        "cpp": ["int", "float", "double", "char", "void", "bool", "auto", "const", "static", "extern", "register", "volatile", "inline", "virtual", "explicit", "friend", "class", "struct", "union", "enum", "namespace", "using", "template", "typename", "public", "private", "protected", "if", "else", "for", "while", "do", "switch", "case", "default", "break", "continue", "return", "goto", "try", "catch", "throw", "new", "delete", "this", "nullptr", "true", "false"],
        "ruby": ["def", "class", "module", "if", "elsif", "else", "unless", "case", "when", "for", "while", "until", "begin", "rescue", "ensure", "end", "return", "yield", "super", "self", "nil", "true", "false", "require", "include", "extend", "attr_accessor", "attr_reader", "attr_writer"],
        "go": ["func", "package", "import", "var", "const", "type", "struct", "interface", "map", "chan", "if", "else", "for", "range", "switch", "case", "default", "fallthrough", "return", "goto", "break", "continue", "defer", "go", "select", "true", "false", "iota", "nil"],
        "rust": ["fn", "let", "const", "static", "struct", "enum", "union", "trait", "impl", "mod", "use", "pub", "crate", "super", "self", "Self", "if", "else", "match", "for", "loop", "while", "return", "break", "continue", "async", "await", "move", "ref", "mut", "dyn", "unsafe", "extern", "where", "where"],
        "php": ["function", "class", "interface", "trait", "namespace", "use", "if", "elseif", "else", "for", "foreach", "while", "do", "switch", "case", "default", "return", "break", "continue", "try", "catch", "finally", "throw", "new", "static", "public", "private", "protected", "final", "abstract", "const", "define", "echo", "print", "var", "global", "isset", "empty", "unset", "true", "false", "null"],
        "c": ["int", "float", "double", "char", "void", "short", "long", "signed", "unsigned", "const", "volatile", "static", "extern", "register", "auto", "struct", "union", "enum", "typedef", "if", "else", "for", "while", "do", "switch", "case", "default", "break", "continue", "return", "goto", "sizeof", "define", "include"]
    ]
    
    // 高亮代码
    static func highlight(code: String, language: String) -> Text {
        let lowercaseLanguage = language.lowercased()
        let keywords = keywords[lowercaseLanguage] ?? []
        
        var result = Text("")
        let lines = code.components(separatedBy: "\n")
        
        for (index, line) in lines.enumerated() {
            var highlightedLine = Text(line)
            
            // 高亮关键词
            for keyword in keywords {
                if line.contains(keyword) {
                    highlightedLine = highlightKeyword(in: highlightedLine, keyword: keyword)
                }
            }
            
            // 高亮字符串
            highlightedLine = highlightStrings(in: highlightedLine, code: line)
            
            // 高亮注释
            highlightedLine = highlightComments(in: highlightedLine, code: line)
            
            result = result + highlightedLine
            
            if index < lines.count - 1 {
                result = result + Text("\n")
            }
        }
        
        return result
            .font(.system(.body, design: .monospaced))
            .foregroundColor(.primary)
    }
    
    private static func highlightKeyword(in text: Text, keyword: String) -> Text {
        // 简单实现：如果包含关键词，将关键词设置为紫色
        // 实际应该使用正则表达式匹配完整的单词
        if keyword.count > 2 { // 避免匹配太短的关键词
            return text.foregroundColor(.purple)
        }
        return text
    }
    
    private static func highlightStrings(in text: Text, code: String) -> Text {
        // 检查是否有字符串
        if code.contains("\"") || code.contains("'") {
            return text.foregroundColor(.green)
        }
        return text
    }
    
    private static func highlightComments(in text: Text, code: String) -> Text {
        // 检查是否有注释
        if code.contains("//") || code.contains("/*") || code.contains("#") {
            return text.foregroundColor(.gray)
        }
        return text
    }
}

// 改进的 CodeBlockView，使用语法高亮
struct HighlightedCodeBlockView: View {
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
            
            // 代码内容（带语法高亮）
            ScrollView(.horizontal, showsIndicators: true) {
                CodeHighlighter.highlight(code: code, language: language)
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
            HighlightedCodeBlockView(
                language: "swift",
                code: """
func greet(name: String) -> String {
    let message = "Hello, \\(name)!"
    // 这是注释
    return message
}

class Person {
    var name: String
    init(name: String) {
        self.name = name
    }
}
"""
            )
            
            HighlightedCodeBlockView(
                language: "python",
                code: """
def greet(name):
    message = f"Hello, {name}!"
    # 这是注释
    return message

class Person:
    def __init__(self, name):
        self.name = name
"""
            )
        }
        .padding()
    }
    .frame(width: 600, height: 400)
}
