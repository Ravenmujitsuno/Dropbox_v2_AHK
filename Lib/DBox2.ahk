/*
        Class DBox2
            Allows direction manipulation of Dropbox files and folders
            © 2021 Benjamin Meder
            
            Help reference: https://www.dropbox.com/developers/documentation/http/documentation
            
            Most methods set this.LastResponse to the last HTTP response code received.
            This is usually 200 if the operation succeeded. See the help reference for 
            what other values might mean. This is useful for troubleshooting.
            
        Members:
            ; AppKey                   - Obtained when you register your app with Dropbox
            ; AppSecret                - Obtained when you register your app with Dropbox
            ; AccessLevel              - Chosen when you register your app with Dropbox
            ; OauthToken               - Authorization token from GetAuthorizationTokens() and GetAccessTokens()
            ; OauthTokenSecret         - Authorization token from GetAuthorizationTokens() and GetAccessTokens()
            ; LastResponse             - The last HTTP response code received.
            
        Methods:
            GetMetadata()               - Retrieves file and folder metadata. Simular to a directory listing.
            GetTemporaryLink()          - Get a temporary URL/Link for a specific file to download it        
            Search()                    - Search for files and folders
            Upload()                    - Upload a file to a specific path (incl Filename)

            ; GetAppKeys               - Automates the generation of all of the application and authorization keys.
            ; GetAccessTokens()        - Gets the access tokens needed for the api calls.
            ; GetAccountInfo()         - Retrieves information about the user's account.
            ; GetCopyReference()       - Creates and returns a copy_ref to a file.
            ; GetDelta()               - A way to keep up with changes to files and folders in a user's Dropbox.
            ; GetFile()                - Downloads a file.
            ; GetMediaLink()           - Returns a link directly to a file.
            ; GetRevisions()           - Obtains metadata for the previous revisions of a file.
            ; GetShareLink()           - Creates and returns a Dropbox preview link to files or folders
            ; PutFile()                - Uploads a file.
            ; RestoreFile()            - Restores a file path to a previous revision.
            ; GetThumbnail()           - Gets a thumbnail for an image.
            ; UploadChunk()            - Uploads large files to Dropbox in mulitple chunks.
            ; UploadCommit()           - Completes an upload initiated by the UploadChunk() method.
            
        The various fileops calls provide the standard file operations. Files and folders can be 
        moved, copied, or deleted. Folders can be created.
            
            DeleteFile()                - Deletes a file or folder.

            ; Copy()         - Copies a file or folder to a new location.
            ; Move()         - Moves a file or folder to a new location.
            ; CreateFolder() - Creates a folder.
*/

#Include Lib\WinHttpRequest.ahk
#Include Lib\json.ahk

class DBox2
{
    static SEARCH_URL := "https://api.dropboxapi.com/2/files/search_v2"
    static REQUEST_TOKEN_URL := "https://api.dropboxapi.com/oauth2/token"
    static DOWNLOAD_URL := "https://content.dropboxapi.com/2/files/download"
    static METADATA_URL := "https://api.dropboxapi.com/2/files/get_metadata"
    static TEMPORARY_LINK := "https://api.dropboxapi.com/2/files/get_temporary_link"
    static UPLOAD_URL := "https://content.dropboxapi.com/2/files/upload"
    static DELETE_URL := "https://api.dropboxapi.com/2/files/delete_v2"

    
    
/****************************************************************************************
	Method: __new(AppKey := "", AppSecret := "", AccessLevel := "sandbox", OauthToken := "", OauthTokenSecret := "")
		Stores the application and authorization keys in the object

	Parameters:
		AppKey           - The App Key (See Remarks)
		AppSecret        - The App Secret (See Remarks)
		AccessLevel      - This is either "sandbox", if you chose a folder as the root directory,
                           or "dropbox", if you chose to access the entire Dropbox.
		OauthToken       - This is obtained by a previous call to GetAuthorizationTokens() or GetAccessTokens()
		OauthTokenSecret - This is obtained by a previous call to GetAuthorizationTokens() or GetAccessTokens()

	Remarks:
		Obtain an AppKey and AppSecret by going to https://www.dropbox.com/developers/apps/create.
        Be sure to select the Core API and the correct access level. This only needs to be 
        done once for each application, because the keys never expire. Be sure to SAVE 
        THE TOKENS for later use!
        
        Use the GetAppKeys() method for a automated approach to geting these keys.

	Returns:
		Nothing
*/
    __New(AppKey := "", AppSecret := "", AccessLevel := "sandbox", AccessToken := "", OauthToken := "", OauthTokenSecret := "")
    {
        this.AppKey := AppKey
      , this.AppSecret := AppSecret
      , this.AccessLevel := AccessLevel
      , this.AccessToken := AccessToken
    ;   , this.OauthToken := OauthToken
    ;   , this.OauthTokenSecret := OauthTokenSecret
    }
    

/****************************************************************************************
	Method: Search(Query, Path := "", FileExtensions := "")
		Returns metadata for all files and folders whose filename contains the given 
        search string as a substring. Searches are limited to the folder path and its 
        sub-folder hierarchy provided in the call.


	Parameters:
		Query            - The search string. Must be at least three characters long.
                      
        Path             - The path to the folder you want to search from.

        FileExtensions   - Search for specific FileExtension

	Returns:
		An object containing metadata entries for any matching files and folders. See the Help reference.
*/
    Search(Query, Path := "", FileExtension := "")
    {

        InOutHeader := ""
            . "Authorization: " this.AccessToken 
            . "`nContent-Type: application/json"
        
        InOutData = {"query":"%Query%"}

        If (FileExtension) && (Path)
            InOutData = {"query":"%Query%","options":{"path":"%Path%","file_Extension":["%FileExtension%"]}}
        If (FileExtension) && !(Path)
            InOutData = {"query":"%Query%","options":{"file_Extensions":["%FileExtension%"]}}
        If (Path) && !(FileExtension)
            InOutData = {"query":"%Query%","options":{"path":"%Path%"}}
        
        OutputDebug % "========================= Search Out =========================`n"
        OutputDebug % "Search.OutHeader = " InOutHeader "`n"
        OutputDebug % "Search.OutData = " InOutData "`n"

        WinHttpRequest(this.SEARCH_URL, InOutData, InOutHeader, "Proxy:localhost:8888")
        
        OutputDebug % "========================= Search IN =========================`n"
        OutputDebug % "Search.InHeader = " InOutHeader "`n"
        OutputDebug % "Search.InData = " InOutData "`n`n`n"

        RegExMatch(InOutHeader, "HTTP/\d\.\d\h\K\d{3}", Response)
        this.LastResponse := Response
        return json.load(InOutData)
    }

/****************************************************************************************
	Method: GetTemporaryLink(path)
		Gets a Temporary Link to the path

	Parameters:
		path      - The path to the file you want to retrieve. This is relative to the app folder
                      or the Dropbox root depending on the AccessLevel. This should NOT point to a folder.

	Returns:
		An URL for downloaded.
*/
    GetTemporaryLink(path)
    {
        InOutHeader := ""
            . "Authorization: " this.AccessToken 
            . "`nContent-Type: application/json"
        
        InOutData = {"path":"%Path%"}

        OutputDebug % "========================= TemporaryLink Out =========================`n"
        OutputDebug % "TemporaryLink.OutHeader = " InOutHeader "`n"
        OutputDebug % "TemporaryLink.OutData = " InOutData "`n"

        WinHttpRequest(this.TEMPORARY_LINK, InOutData, InOutHeader, "Charset:UTF-8`nProxy:localhost:8888")
        
        OutputDebug % "========================= TemporaryLink IN =========================`n"
        OutputDebug % "TemporaryLink.InHeader = " InOutHeader "`n"
        OutputDebug % "TemporaryLink.InData = " InOutData "`n`n`n"

        RegExMatch(InOutHeader, "HTTP/\d\.\d\h\K\d{3}", Response)
        this.LastResponse := Response
        return json.load(InOutData)
    }


    /****************************************************************************************
	Method: GetMetadata(Path := "")
    
		Retrieves file and folder metadata. See the help reference.

	Parameters:
		Path           - The path to the file or folder. 

	Returns:
		An object containing the metadata for the file or folder at the given <path>. If <path> 
        represents a folder and the list parameter is true, the object will also include a 
        sub-object containing the metadata for the folder's contents.
*/
    GetMetadata(Path := "")
    {

        InOutHeader := ""
            . "Authorization: " this.AccessToken 
            . "`nContent-Type: application/json"
        
        InOutData = {"path":"%Path%"}

        OutputDebug % "========================= Metadata Out =========================`n"
        OutputDebug % "Metadata.OutHeader = " InOutHeader "`n"
        OutputDebug % "Metadata.OutData = " InOutData "`n"

        WinHttpRequest(this.METADATA_URL, InOutData, InOutHeader, "Charset:UTF-8`nProxy:localhost:8888")
        
        
        OutputDebug % "========================= Metadata In =========================`n"
        OutputDebug % "Metadata.InHeader = " InOutHeader "`n"
        OutputDebug % "Metadata.InData = " InOutData "`n`n`n"


        RegExMatch(InOutHeader, "HTTP/\d\.\d\h\K\d{3}", Response)
        this.LastResponse := Response
        return json.load(InOutData)

    }


    /****************************************************************************************
	Method: Upload(uploadFolder, locPath, name, binaryTrue := "0")
        
		Uploads a file to a specific path. Right now it will overwrite the file if it allready exists.
        See the help reference.

    Parameters:

        uploadFolder    - the path inkl Filename where the file should be uploaded in Dropbox
        locPath         - The local path. f.e. d:\
        name            - the name of the File
        binaryTrue      - Is the file binary? Then set it to 1

	Returns:
		An object containing the information of the uploaded file. There is no check right now
        if the upload was finished correctly.

*/
    Upload(uploadFolder, locPath, name, binaryTrue := "0")
    {

        DBarg = {"path":"%uploadFolder%/%name%","mode":{".tag":"overwrite"},"autorename":false}
        
        If (binaryTrue = "1")
        {
            InOutHeader := ""
                . "Authorization: " this.AccessToken 
                . "`nContent-Type:  application/octet-stream"
                . "`nDropbox-API-Arg: " DBarg

            Set InOutData = new ComObjCreate("adodb.stream")
            InOutData.Type = adTypeBinary
            InOutData.Open
            InOutData.LoadFromFile %locPath%%name%

        } 
        Else
        {
            InOutHeader := ""
                . "Authorization: " this.AccessToken 
                . "`nContent-Type: text/plain; charset=dropbox-cors-hack"
                . "`nDropbox-API-Arg: " DBarg
            FileRead, InOutData, %locPath%%name%
        }



        OutputDebug % "========================= Upload Out =========================`n"
        OutputDebug % "Search.OutHeader = " InOutHeader "`n"
        OutputDebug % "Search.OutData = " InOutData "`n"

        WinHttpRequest(this.UPLOAD_URL, InOutData, InOutHeader, "Proxy:localhost:8888")
        

        OutputDebug % "========================= Upload In =========================`n"
        OutputDebug % "Search.InHeader = " InOutHeader "`n"
        OutputDebug % "Search.InData = " InOutData "`n`n`n"


        RegExMatch(InOutHeader, "HTTP/\d\.\d\h\K\d{3}", Response)
        this.LastResponse := Response
        return InOutData

    }

        /****************************************************************************************
	Method: DeleteFile(path)
        
		Retrieves file and folder metadata. See the help reference.

    Parameters:

        path        - the path inkl Filename where the file should be delete in Dropbox
        
	Returns:
		An object containing the information of the deleted file. There is no check right now
        if the deletion was finished correctly.
*/
    DeleteFile(path)
    {

        DBarg = {"path":"%path%"}

        InOutHeader := ""
            . "Authorization: " this.AccessToken 
            . "`nContent-Type: application/json"
        
        InOutData = %DBarg%


        OutputDebug % "========================= Upload Out =========================`n"
        OutputDebug % "Search.OutHeader = " InOutHeader "`n"
        OutputDebug % "Search.OutData = " InOutData "`n"

        WinHttpRequest(this.DELETE_URL, InOutData, InOutHeader, "Proxy:localhost:8888")
        

        OutputDebug % "========================= Upload In =========================`n"
        OutputDebug % "Search.InHeader = " InOutHeader "`n"
        OutputDebug % "Search.InData = " InOutData "`n`n`n"


        RegExMatch(InOutHeader, "HTTP/\d\.\d\h\K\d{3}", Response)
        this.LastResponse := Response
        return InOutData

    }
}