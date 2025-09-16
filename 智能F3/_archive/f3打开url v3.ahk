; ======================================================================================================================
; AHK v2 Script: Open Selected URL or Coupang Product ID (Logic Perfected)
; Author:          Senior Software Engineer (AI)
; Description:     最终版。修正了逻辑优先级，先判断URL，再判断ID。使用更精确的ID匹配模式，避免误判。
; Version:         4.0 - Logic Perfected. Checks for URL first, then uses a precise, anchored regex for the ID.
; ======================================================================================================================

#Requires AutoHotkey v2.0+
#Warn

F3:: {
    local TIMEOUT_MS := 1500
    local savedClipboard := ClipboardAll()
    A_Clipboard := ""
    
    SendInput "^c"
    Sleep(100)

    if !ClipWait(TIMEOUT_MS / 1000, 1) {
        A_Clipboard := savedClipboard
        ToolTip("无法获取选中内容或超时")
        Return
    }

    local clipboardText := A_Clipboard
    A_Clipboard := savedClipboard
    
    if (clipboardText == "") {
        Return
    }

    ; ------------------------------------------------------------------
    ; --- 步骤 1: (最高优先级)  检测是否为通用网址 ---
    ; ------------------------------------------------------------------
    local urlRegex := "i)^(https?:\/\/)?([\w-]+\.)+[\w-]+(\.[\w-]+)*(\/[\S]*)?$"
    if RegExMatch(Trim(clipboardText), urlRegex, &match) {
        local urlToOpen := match[0]
        if !RegExMatch(urlToOpen, "i)^https?:\/\/") {
            urlToOpen := "http://" . urlToOpen
        }
        Run(urlToOpen)
        Return ; <<== 任务完成，立即退出
    }

    ; ------------------------------------------------------------------
    ; --- 步骤 2: (次高优先级) 如果不是网址，再检测是否为 Coupang ID ---
    ; ------------------------------------------------------------------
    
    ; [FINAL FIX] 使用一个精确的、带锚点的正则表达式
    ; 这个表达式要求整个字符串除了前后空白外，必须且只能是10位数字。
    ; ^     => 字符串开头
    ; \s*   => 任意数量的空白字符 (空格, Tab, 换行符等)
    ; (\d{10}) => 捕获10位数字
    ; \s*   => 任意数量的空白字符
    ; $     => 字符串结尾
    local coupangIdRegex := "^\s*(\d{10})\s*$"
    if RegExMatch(clipboardText, coupangIdRegex, &match) {
        ; 匹配成功，我们需要的10位数字在 match[1] 中
        local coupangId := match[1]
        local coupangUrl := "https://www.coupang.com/vp/products/" . coupangId
        Run(coupangUrl)
        Return
    }

    ; 如果以上所有条件都不满足，脚本将无任何操作，自动结束。
}
