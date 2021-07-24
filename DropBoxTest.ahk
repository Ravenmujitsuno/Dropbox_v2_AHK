#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include WinHttpRequest.ahk
#Include JSON.ahk
; #Include ParseJSON
; #Include common.ahk
#Include DBox2.ahk

queryString := ""
    
AccessLevel := "dropbox"
AppKey := "awgqazfcxuiaz00" ; Can be used as Username / client ID
AppSecret := "fdf4v8pmwz8nzru" ; Can be used as Password for HTTP basic authentification / client secret
AccessToken := "Bearer uAjwFVUI5bIAAAAAAAAAAarq1AqLzWEGUEKhCR6FLSnUu9gA25zcgcbhnymNMh-Z"

; Results = {"has_more":false,"matches":[{"match_type":{".tag":"filename"},"metadata":{".tag":"metadata","metadata":{".tag":"folder","id":"id:MqGW1_oEjJcAAAAAAAAALA","name":"update","path_display":"/update","path_lower":"/update"}}},{"match_type":{".tag":"filename"},"metadata":{".tag":"metadata","metadata":{".tag":"file","client_modified":"2021-07-15T08:50:09Z","content_hash":"c0459c4d0a2f4adf6848c62c12b4e48801030465f5c507ec899586d4ead076b4","id":"id:MqGW1_oEjJcAAAAAAAAALQ","is_downloadable":true,"name":"PSUpdate_Base-v1.3.6.0_Handheld_v1.3.1.1_OMT.bin","path_display":"/update/PSUpdate_Base-v1.3.6.0_Handheld_v1.3.1.1_OMT.bin","path_lower":"/update/psupdate_base-v1.3.6.0_handheld_v1.3.1.1_omt.bin","rev":"015c7258ef012d60000000240fb2790","server_modified":"2021-07-15T08:50:09Z","size":46101744}}}]}

MyDB := new DBox(AppKey, AppSecret, AccessLevel, AccessToken)
Results := MyDb.Search("PSUpdate", "/update", "bin")
; Results = {"has_more":false,"matches":[{"match_type":{".tag":"filename"},"metadata":{".tag":"metadata","metadata":{".tag":"folder","id":"id:MqGW1_oEjJcAAAAAAAAALA","name":"update","path_display":"/update","path_lower":"/update"}}},{"match_type":{".tag":"filename"},"metadata":{".tag":"metadata","metadata":{".tag":"file","client_modified":"2021-07-15T08:50:09Z","content_hash":"c0459c4d0a2f4adf6848c62c12b4e48801030465f5c507ec899586d4ead076b4","id":"id:MqGW1_oEjJcAAAAAAAAALQ","is_downloadable":true,"name":"PSUpdate_Base-v1.3.6.0_Handheld_v1.3.1.1_OMT.bin","path_display":"/update/PSUpdate_Base-v1.3.6.0_Handheld_v1.3.1.1_OMT.bin","path_lower":"/update/psupdate_base-v1.3.6.0_handheld_v1.3.1.1_omt.bin","rev":"015c7258ef012d60000000240fb2790","server_modified":"2021-07-15T08:50:09Z","size":46101744}}}]}
; MsgBox % Results
J := json.load(Results)
; obj := ExploreObj(J)
; OutputDebug, %obj% 
if(0)
{
    for key, value in J.matches
    {
        for i, o in value.metadata.metadata
            if (o = "file")
            {
                ; OutputDebug % key " " value.metadata.metadata.path_display "`n"
                objMetadata := MyDB.GetMetadata(value.metadata.metadata.path_display)
                ; OutputDebug % objMetadata.size "`n"
                
                objGetURL := MyDB.GetTemporaryLink(value.metadata.metadata.path_display)
                ; OutputDebug % objGetURL.link
                
                DownloadFile(objGetURL.link, "D:\" value.metadata.metadata.name)

            }
    }
}

if(1)
{
    for key, value in J.matches
    {
        for i, o in value.metadata.metadata
		{
            if (o = "file")
            {
                MyDB.DeleteFile(value.metadata.metadata.path_display)
            }
		}
	}
    MyDB.Upload("/update", "D:\", "PSUpdate_Base-v1.3.6.0_Handheld_v1.3.1.1_OMT.bin")


}


OutputDebug, finished`n
ExitApp
