; ======================================================================================================================
; AHK v2 Script: Open Selected URL or Coupang Product ID
; Author:          Senior Software Engineer (AI)
; Description:     按 F3 获取当前选中的文本。
;                  1. 如果文本是 Coupang 商品ID，则打开对应的商品页面。
;                  2. 如果不是，则检查其是否为通用网址并打开。
;                  这个脚本经过精心设计，不会影响用户当前的剪贴板内容。
; Version:         2.0 - Added Coupang Product ID detection.
; ======================================================================================================================

#Requires AutoHotkey v2.0+
#Warn ; 启用警告是良好的实践

/**
 * 核心功能热键 F3
 * 当按下 F3 时，执行此代码块。
 */
F3:: {
    ; --- 步骤 1: 安全地捕获选中的文本 (逻辑不变) ---
    local savedClipboard := A_Clipboard
    A_Clipboard := ""
    Send "^c"

    if !ClipWait(1) {
        A_Clipboard := savedClipboard
        Return
    }
    local selectedText := A_Clipboard
    A_Clipboard := savedClipboard

    ; --- 步骤 2: 分析并处理捕获的文本 ---
    local cleanedText := Trim(selectedText)

    if (cleanedText == "") {
        Return
    }
    
    ; --- 步骤 2a: 优先检测 Coupang 商品 ID ---
    ; Coupang ID 通常是9到12位纯数字。我们使用一个范围 (例如 8-15) 来增加匹配的灵活性。
    ; 使用 ^ 和 $ 锚点确保选中的是纯粹的ID，而不是包含数字的更长文本。
    local coupangIdRegex := "^\d{10,10}$"

    if RegExMatch(cleanedText, coupangIdRegex) {
        ; 如果匹配，则判定为 Coupang ID
        local coupangUrl := "https://www.coupang.com/vp/products/" . cleanedText
        Run(coupangUrl)
        Return ; ID 已处理，任务完成，退出函数

    } else {
        ; --- 步骤 2b: 如果不是 Coupang ID，则检测是否为通用网址 ---
        local urlRegex := "i)^(https?:\/\/)?((www\.)|([\d\p{L}-]+\.))[\p{L}\d.-]+\.[\p{L}]{2,8}(\/[\S]*)?$"

        if RegExMatch(cleanedText, urlRegex) {
            local urlToOpen := cleanedText

            if !RegExMatch(urlToOpen, "^https?:\/\/") {
                urlToOpen := "http://" . urlToOpen
            }
            Run(urlToOpen)
        }
        ; 如果也不是通用网址，则不执行任何操作。
    }
}
