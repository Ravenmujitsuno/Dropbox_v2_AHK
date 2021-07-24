#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#singleinstance force

#include H:/Engineering/FHI/!SourceCode/Lib/common.ahk


UpdateCheck(New, Old, URL)
{

	global
	
	if (A_IPAddress1 = "127.0.0.1" || A_IPAddress2 = "127.0.0.1")
		Return 4
	if RoundTripTime("46.30.58.134") < 0
		Return 4
	
	/*****************************
	Check if the files already exist and if yes, then rename it to oldPartSensVersion
	*/
	
	If FileExist(New)
	{	
		
		If FileExist(Old)
			FileDelete, %Old%
			
		;FileMove, %New%, %Old%, 1
		ErrorCount := MoveFilesAndFolders(New, Old, 1)
		if (ErrorCount != 0)
		{
			MsgBox, , , %ErrorCount% files/folders could not be moved., %MyTimer%
			Return 3
		}
	}

	
	/*****************************
	Check if the files already exist and if yes, then rename read the ini for the old Version Number
	*/

	If FileExist(Old)
		IniRead, oldVersion, %Old%, General, Version
	else
		oldVersion := 0

	/*****************************
	Download from OMT Site the INI Files
	*/
				
	UrlDownloadToFile, %URL%, %New%

	If !FileExist(New)
		Return 3
	else	
	{
		FileReadLine, checkGeneral, %New%, 1
		;MsgBox % checkGeneral
		If (checkGeneral != "[General]")
			Return 2
	}
	
	IniRead, newVersion, %New%, General, Version
	; MsgBox % "New = " newVersion " Old = " oldVersion
	
	
	If (oldVersion < newVersion)
	{
		MsgBox, 4, , %checkUpdateFound%, 5
		if MsgBox, No
			Return 4
		myProgressBar("+5", checkUpdateFound )
		myProgressBar("+10", checkUpdateDownloading )
		IniRead, OutputVarDatei, %New%, General, Datei
		DownloadFile(OutputVarDatei, "c:\!scripts\Updates\PSupdate.bin")
		Sleep, 50
		myProgressBar("+10", checkUpdateDLfinished )
		;MsgBox, , , %checkUpdateDLfinished%, %MyTimer%
		Return 1
	}

	Return 0
}
