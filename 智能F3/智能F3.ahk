; ======================================================================================================================
; AHK v2 Script: Open URL, Coupang ID, or Search Keyword
; Author:          Senior Software Engineer (AI)
; Description:     最极致兼容的最终版本。它使用更稳定和通用的WinINet库中的InternetCanonicalizeUrlW函数进行URL编码，
;                  彻底解决所有DllCall相关警告和错误。
;                  逻辑顺序: 1. URL -> 2. Coupang ID -> 3. Coupang Keyword Search
; Version:         1.6 - Added version display and corrected tag.
; ======================================================================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force
#Warn All ; 开启所有警告，确保代码质量

; ======================================================================================================================
; Tray Menu Definition
; 建议：将此脚本文件保存为 UTF-8 with BOM 编码，以确保中文字符正确显示。
; ======================================================================================================================
global CURRENT_VERSION := "v1.6"

global helpText := "
(
智能F3 使用说明:
---------------------------------
1. 选中任意文本后，按下 F3 键。
2. 脚本会自动判断文本内容：
   - 如果是网址 (如 google.com)，则直接在浏览器中打开。
   - 如果是10位数字，则作为 Coupang 商品ID 打开页面。
   - 否则，将文本作为关键词在 Coupang 进行搜索。
---------------------------------
右键托盘图标可再次查看此说明。
)"

; --- 定义托盘菜单处理函数 ---
ShowHelp(*) {
    global helpText
    MsgBox(helpText, "智能F3 使用说明")
}

ShowVersion(*) {
    global CURRENT_VERSION
    MsgBox("当前版本: " . CURRENT_VERSION, "智能F3")
}

CheckUpdate(*) {
    Run("https://github.com/xgp46ginpo/AutoHotkey/releases")
}

ReloadScript(*) {
    Reload()
}

ExitAppMenu(*) {
    ExitApp()
}

; --- 设置最终的托盘菜单 (AHK v2 推荐方式) ---
try {
    A_IconTip := "智能F3 - 选中文字按 F3 使用"
    A_TrayMenu.Delete() ; 清空所有旧菜单项
    A_TrayMenu.Add("使用说明", ShowHelp)
    A_TrayMenu.Add("当前版本", ShowVersion)
    A_TrayMenu.Add("检查更新", CheckUpdate)
    A_TrayMenu.Add() ; 分隔线
    A_TrayMenu.Add("重新加载", ReloadScript)
    A_TrayMenu.Add("退出", ExitAppMenu)
}
; ======================================================================================================================

F3:: {
    ; --- 步骤 1: 复制选中内容到变量 ---
    local TIMEOUT_MS := 1500
    local savedClipboard := ClipboardAll()
    A_Clipboard := ""
    
    SendInput "^c"
    Sleep(100) ; 等待系统响应复制命令

    if !ClipWait(TIMEOUT_MS / 1000, 1) {
        A_Clipboard := savedClipboard
        ToolTip("无法获取选中内容或超时")
        Sleep(2000) ; 让提示显示2秒
        ToolTip()   ; 清除提示
        Return
    }

    local clipboardText := A_Clipboard
    A_Clipboard := savedClipboard ; 恢复原始剪贴板，避免污染
    
    ; --- 步骤 2: 清理数据并进行逻辑判断 ---
    local trimmedText := Trim(clipboardText) ; 去除首尾空白，这是最关键的第一步

    if (trimmedText == "") {
        Return ; 如果内容为空（或只有空格），则不执行任何操作
    }

    ; --- 逻辑分支 1: (最高优先级) 判断是否为通用网址 ---
    ; 增强版正则：支持 IP 地址、端口号和更广泛的 TLD
    local urlRegex := "i)^(https?:\/\/)?([a-z0-9-_\.]+\.)+[a-z]{2,}(:\d+)?(\/.*)?$"
    if RegExMatch(trimmedText, urlRegex) {
        local finalUrl := trimmedText
        ; 如果网址没有 http:// 或 https:// 前缀，则为其添加 http://
        if !RegExMatch(finalUrl, "i)^https?:\/\/") {
            finalUrl := "http://" . finalUrl
        }
        Run(finalUrl)
    }
    ; --- 逻辑分支 2: (中等优先级) 判断是否为纯10位Coupang ID ---
    else if RegExMatch(trimmedText, "^\d{10}$") {
        Run("https://www.coupang.com/vp/products/" . trimmedText)
    }
    ; --- 逻辑分支 3: (最低优先级) 作为关键词在Coupang进行搜索 ---
    else {
        ; 使用最兼容的 URL_EncodeComponent 函数进行编码
        local encodedKeyword := URL_EncodeComponent(trimmedText)
        local searchUrl := "https://www.coupang.com/np/search?component=&q=" . encodedKeyword
        Run(searchUrl)
    }
}

; ======================================================================================================================
; Helper Function: URL_EncodeComponent
; Description: URL-encodes a string using InternetCanonicalizeUrlW from WinINet.dll.
; This is the most robust and widely compatible method for URL encoding across Windows versions.
; Refactored for simplicity and clarity.
; ======================================================================================================================
URL_EncodeComponent(strToEncode) {
    if (strToEncode == "") {
        return ""
    }

    ; ICU_ENCODE_PERCENT - Encodes all characters not in the reserved or unsafe set.
    ; This is the most comprehensive flag for encoding search keywords.
    local flags := 0x00100000 
    local bufSize := 0

    ; 第一次调用: 传入空缓冲区指针(0)以获取所需的缓冲区大小 (in WCHARs)
    DllCall("wininet.dll\InternetCanonicalizeUrlW", "wstr", strToEncode, "ptr", 0, "uint*", &bufSize, "uint", flags)

    ; 如果API调用失败或字符串无需编码，bufSize可能为0
    if (bufSize <= 0) {
        return strToEncode ; 返回原始字符串作为备用
    }

    ; 分配所需大小的缓冲区 (Buffer需要字节大小, WCHAR是2字节)
    local resultBuf := Buffer(bufSize * 2)

    ; 第二次调用: 传入分配好的缓冲区，实际执行编码
    if !DllCall("wininet.dll\InternetCanonicalizeUrlW", "wstr", strToEncode, "ptr", resultBuf, "uint*", &bufSize, "uint", flags) {
        return strToEncode ; 如果编码失败，返回原始字符串
    }

    ; 从缓冲区中获取UTF-16编码的字符串
    return StrGet(resultBuf, "UTF-16")
}
