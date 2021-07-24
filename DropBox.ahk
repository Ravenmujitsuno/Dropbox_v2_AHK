#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include lib\WinHttpRequest.ahk
#Include lib\JSON.ahk
; #Include ParseJSON
; #Include common.ahk
; #Include lib\DBox2.ahk

#Include .env.def.save



MsgBox % AppKey