#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include .env.dev.save ; This file is used to add sensitiv variables. Check .env.dev.example

#Include lib\WinHttpRequest.ahk
#Include lib\JSON.ahk

#Include lib\common.ahk
#Include lib\DBox2.ahk

queryString := ""
    

OutputDebug, % "Creating new class`n"
MyDB := new DBox2(AppKey, AppSecret, AccessLevel, AccessToken)

if(0)   ; Don't execute. If yes, then change to 1
        ; This must be set to 1 if you want to download or delete the files
{
    OutputDebug, % "---------- Search for PSUpdate file in /update with the extensions bin`n"
    Results := MyDb.Search("PSUpdate","/update","adn")
}


if(0) ; turn this only on, if there is a JSON Object in Results. F.e. the above Search
{
    OutputDebug, % "---------- Going thorugh the Results`n"
    for key, value in Results.matches
    {
        for k, v in value.metadata.metadata
        {
            if (v = "file")
            {
                ; Get the Metadata if the resulted file(s)
                objMetadata := MyDB.GetMetadata(value.metadata.metadata.path_display)
                
                ; Get a temporary Link for the file. It's possible to download it with the
                ; GetFile, but with the temporary Link it is possible to track the Process
                ; of the download.
                objGetURL := MyDB.GetTemporaryLink(value.metadata.metadata.path_display)
            }
        }
    }
}

if(0) ; Use this only, if you have a Temporary Link to Download
{
    DownloadFile(objGetURL.link, "D:\" value.metadata.metadata.name)
}

if(0)
{
    for key, value in Results.matches
    {
        for i, o in value.metadata.metadata
		{
            if (o = "file")
            {
                MyDB.DeleteFile(value.metadata.metadata.path_display)
            }
		}
	}
}

if(1)
{
    OutputDebug, % "--------- Uploading starts"
    MyDB.Upload("/update", "D:\", "PSUpdate_Base-v1.3.6.0_Handheld_v1.3.1.1_OMT.bin", 1)
    OutputDebug, % "--------- Uploading finished"
}