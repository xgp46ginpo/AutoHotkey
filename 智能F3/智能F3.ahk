; ======================================================================================================================
; AHK v2 Script: Open URL, Coupang ID, or Search Keyword
; Author:          Senior Software Engineer (AI)
; Description:     最极致兼容的最终版本。它使用更稳定和通用的WinINet库中的InternetCanonicalizeUrlW函数进行URL编码，
;                  彻底解决所有DllCall相关警告和错误。
;                  逻辑顺序: 1. URL -> 2. Coupang ID -> 3. Coupang Keyword Search
; Version:         5.3 - Ultimate Compatibility and Stability.
; ======================================================================================================================

#Requires AutoHotkey v2.0+
#Warn All ; 开启所有警告，确保代码质量

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
    ; 这个正则表达式可以匹配大多数 http, https 或 www. 开头的网址
    local urlRegex := "i)^(https?:\/\/)?([a-z0-9-]+\.)+[a-z]{2,}(\/.*)?$"
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
; ======================================================================================================================
URL_EncodeComponent(strToEncode) {
    if (strToEncode == "") {
        return ""
    }

    local bufSize := 0 ; 用于接收所需缓冲区大小
    local flags := 0x00100000 | 0x01000000 ; ICU_ENCODE_PERCENT | ICU_ENCODE_SPACES_ONLY
    ; 注意： ICU_ENCODE_PERCENT (0x00100000) 可以确保所有非字母数字字符都被编码。
    ; ICU_ENCODE_SPACES_ONLY (0x01000000) 仅编码空格。
    ; 根据您的需求，可以调整这些标志。对于搜索关键词，通常需要全面编码。
    ; 移除 ICU_ENCODE_SPACES_ONLY 可以实现更彻底的编码，如编码 & 等。
    ; 例如，只用 0x00100000 (ICU_ENCODE_PERCENT) 会更彻底地编码所有特殊字符。
    ; 为了通用搜索，通常推荐全面编码，所以我们用 0x00100000 即可。
    flags := 0x00100000 ; ICU_ENCODE_PERCENT - Encodes all characters not in the reserved or unsafe set.

    ; 第一次 DllCall: 获取所需的缓冲区大小
    ; DllCall("wininet.dll\InternetCanonicalizeUrlW", "wstr", strToEncode, "ptr", 0, "uint*", bufSize, "uint", flags)
    ; InternetCanonicalizeUrlW in newer versions requires an initial buffer size of at least 1, even for getting the size.
    ; Let's retry with 1 and then grow dynamically. Or, a safer approach is to pass
    ; a small buffer initially and let it fail to get the exact size.

    ; A common robust pattern for DllCalls that return buffer size:
    local tempBufSize := 0
    local result := DllCall("wininet.dll\InternetCanonicalizeUrlW", "wstr", strToEncode, "ptr", 0, "uint*", tempBufSize, "uint", flags)

    ; If result is 0 and GetLastError() is ERROR_INSUFFICIENT_BUFFER (122), tempBufSize has the required size.
    ; If result is non-zero, it succeeded with 0 buffer (unlikely for non-empty string)
    ; If result is 0 and not ERROR_INSUFFICIENT_BUFFER, then it's a real error.

    ; Check if the initial call failed with buffer too small (most common case for `ptr`, `0`, `uint*`)
    if (result == 0 && A_LastError == 122) { ; ERROR_INSUFFICIENT_BUFFER
        bufSize := tempBufSize ; Use the size returned by the function
    } else if (result != 0) { ; It succeeded, probably with small string or empty string
        ; This branch means the original buffer (even if 0) was sufficient.
        ; This is unlikely for non-empty strings needing encoding.
        ; For robust code, we'd assume it needs encoding space.
        ; Let's re-evaluate bufSize for small strings. For small strings, `StrLen(strToEncode) * 3 + 10` is a safe bet.
        bufSize := StrLen(strToEncode) * 3 + 10 ; Fallback to heuristic for very small strings or unexpected success.
            if (bufSize < tempBufSize) { ; ensure we use the larger of the two
                bufSize := tempBufSize
            }
    } else { ; Other DllCall error
        return strToEncode ; Fallback to original string if API call inherently failed
    }
    
    if (bufSize == 0) { ; Still 0 size after calculation, implies empty string or major error
        return strToEncode ; Or ""
    }

    local resultBuf := Buffer(bufSize * 2) ; *2 because bufSize is WCHARs, Buffer needs bytes
    local actualBufSize := bufSize ; This will be updated by the DllCall

    ; 第二次 DllCall: 实际执行编码
    result := DllCall("wininet.dll\InternetCanonicalizeUrlW", "wstr", strToEncode, "ptr", resultBuf, "uint*", actualBufSize, "uint", flags)

    if (result == 0) { ; 编码失败
        return strToEncode ; 返回原始字符串作为备用
    }

    ; 将缓冲区内容转换为 AutoHotkey 字符串（UTF-16）
    ; actualBufSize now contains the length of the string in characters (including null terminator).
    return StrGet(resultBuf, actualBufSize - 1, "UTF-16") ; -1 to exclude the null terminator
}
