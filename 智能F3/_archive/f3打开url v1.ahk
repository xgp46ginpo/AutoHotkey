; ======================================================================================================================
; AHK v2 Script: Open Selected URL (Revised)
; Author:          Senior Software Engineer (AI)
; Description:     按 F3 获取当前选中的文本。如果文本是一个有效的网址，则在用户的默认浏览器中打开它。
;                  这个脚本经过精心设计，不会影响用户当前的剪贴板内容。
; Version:         1.1 - Corrected for AHK v2 clipboard handling.
; ======================================================================================================================

#Requires AutoHotkey v2.0+
#Warn ; 启用警告是很好的实践，可以帮助发现这类问题

/**
 * 核心功能热键 F3
 * 当按下 F3 时，执行此代码块。
 */
F3:: {
    ; --- 步骤 1: 安全地捕获选中的文本 ---
    ; 为了不破坏用户原有的剪贴板，我们先保存它。
    ; 在 AHK v2 中, A_Clipboard 会处理所有数据类型 (文本、图片等)。
    local savedClipboard := A_Clipboard  ; <== [FIXED] 使用 A_Clipboard 代替 A_ClipboardAll
    A_Clipboard := "" ; 清空剪贴板，以便 ClipWait 能够检测到新的内容

    Send "^c" ; 发送 Ctrl+C

    ; 等待剪贴板中出现数据，最多等待1秒。
    if ClipWait(1) {
        local selectedText := A_Clipboard
    } else {
        ; 如果1秒内没有复制到任何内容, 恢复剪贴板并静默退出。
        A_Clipboard := savedClipboard
        Return
    }

    ; 关键步骤：立即恢复用户原有的剪贴板。
    A_Clipboard := savedClipboard


    ; --- 步骤 2: 分析捕获的文本 ---
    local cleanedText := Trim(selectedText)

    if (cleanedText == "") {
        Return
    }
    
    ; 使用正则表达式来判断文本是否为网址
    local urlRegex := "i)^(https?:\/\/)?((www\.)|([\d\p{L}-]+\.))[\p{L}\d.-]+\.[\p{L}]{2,8}(\/[\S]*)?$"

    if RegExMatch(cleanedText, urlRegex) {
        ; --- 步骤 3: 如果是网址，则构建并运行 ---
        local urlToOpen := cleanedText

        if !RegExMatch(urlToOpen, "^https?:\/\/") {
            urlToOpen := "http://" . urlToOpen
        }

        Run(urlToOpen)

    } else {
        ; --- 步骤 4: 如果不是网址，则静默处理 ---
        ; 可以取消注释下面的代码来实现调试反馈
        ; ToolTip("选中的内容不是一个有效的网址。")
    }
}
