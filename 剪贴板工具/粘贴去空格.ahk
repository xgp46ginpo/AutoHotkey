#Requires AutoHotkey v2.0

; 热键：Ctrl+Alt+V 去除剪贴板空格并粘贴
^!v::
{
    ; 备份原始剪贴板内容
    try savedClip := ClipboardAll()
    catch
        savedClip := ""
    
    ; 处理剪贴板文本
    try {
        clipText := A_Clipboard
        if (trimmed := Trim(clipText)) != clipText {
            A_Clipboard := trimmed
            Sleep 50  ; 确保剪贴板更新
        }
    }
    
    ; 发送粘贴命令
    Send "^v"
    
    ; 恢复原始剪贴板内容
    if savedClip != "" {
        Sleep 100
        A_Clipboard := savedClip
    }
    return
}

; 可选：剪贴板变化时自动处理（谨慎使用）
/*
OnClipboardChange(ClipChanged)
ClipChanged(Type) {
    if (Type = 1) {  ; 仅处理文本类型
        try {
            if (trimmed := Trim(A_Clipboard)) != A_Clipboard
                A_Clipboard := trimmed
        }
        ; 静默失败，避免干扰
    }
    return true
}
*/