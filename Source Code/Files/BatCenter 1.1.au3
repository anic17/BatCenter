#include-once
;  _____ _          _           _
; |_   _| |        | |         | |
;   | | | |__   ___| |__   __ _| |_ ___  __ _ _ __ ___
;   | | | '_ \ / _ \ '_ \ / _` | __/ _ \/ _` | '_ ` _ \
;   | | | | | |  __/ |_) | (_| | ||  __/ (_| | | | | | |
;   \_/ |_| |_|\___|_.__/ \__,_|\__\___|\__,_|_| |_| |_|
;
;		 On The Fly Plugin to download PlugIns.
;        			Mr.Km | Kvc | Zeek

#include <WinAPIShPath.au3>
; For Processing the  json objects
#include "Includes/json.au3"
; For highly precise Percentage progress calculus ..
#include <Math.au3>
; HTTP ERROR Codes
Global $ERR_CONNECT = 300, $ERR_URL = 301
Global Const $sMessageConnectionError = " > Connection failed.. Internet Connection required."
Global $sMessageInvalidURLstrin = " Error: The URL provided is not a Invalid URL!"
Global $sConMess = " > Connecting to GitHub API...           "
Global $sTablish = " > Establishing secure connection..      "
Global $sConnErrMessage = "Connection Error:                             "
Global Const $sPath2LocalDeirector = @TempDir & "\TheBateam"
Global Const $sStaticJSONfilePath_ = $sPath2LocalDeirector & "\Repos.json"
Global Const $sMainProgramUpdateData = "URL.dat"
; =======================================================================
; Download Raw file from Dbx Guide :
; Normally, you'll have a link like: https://www.dropbox.com/s/hriinb9w3a2107m/Update%20Json.dat
; To get a direct download link, just replace the www.dropbox.com part with dl.dropboxusercontent.com,
; which will give you a link like:
; https://dl.dropboxusercontent.com/s/hriinb9w3a2107m/Update%20Json.dat
; 2 test ,copy that link and paste it in your browser, and it'll download the raw file directly from
; a dropbox
Global Const $sStaticURLtoJSONfile = "https://api.github.com/users/TheBATeam/repos"
; "https://dl.dropboxusercontent.com/s/4os4dk2i6vpvknk/Plugins.json"  ; ?dl=1
; =======================================================================
Global Const $sPrefixDownloadUrl = "/archive/master.zip"
; ======================================================================================
;  HAndles
Global $hCout = ConsoleWrite   ; Cout Var, mod 4 Color output.
Global $hChk = FileExists      ; make custom func
Global $hSrchStr = StringInStr ; sting finder..
Global $hErr = SetError         ; / Exit (%errorlevel%)
Global $hRegexRp = StringRegExpReplace ; For Regular Expressions.
Global $hRegeX = StringRegExp
; 1. JSON obj -> String
; 2. String -> FileHandle
; 3. FileHandle -> Jsonint.
; 4. Jsonint -> Filtered result.
; ========================================================================================
Local $sFileOutPut

If _CmdLine_KeyExists('update') Then
	; $sDownloadlink = _CmdLine_Get('update', $sStaticJSONfilePath_)
	;If _IsAvalidURL($sDownloadlink) And IsConnected() Then
	If IsConnected() Then
		;TrayTip("Establishing secure connection..", @ScriptName, 0)
		_dl($sStaticURLtoJSONfile, " > Updating Local Library Information ...", $sStaticJSONfilePath_)
	Else
		$hCout("Error: Connection required to connect to remote database." & @CRLF)
		Exit ($ERR_URL + $ERR_CONNECT)
	EndIf
ElseIf _CmdLine_KeyExists('get') Then
	Global $sPluginName = _CmdLine_Get('get', False)
	If Not IsConnected() Or Not $sPluginName Then
		Exit ($ERR_CONNECT)
	Else
		Get()
	EndIf
ElseIf _CmdLine_KeyExists('list') Then
	If IsConnected() Then
		; Updates Local file.
		_dl($sStaticURLtoJSONfile, $sConMess, $sStaticJSONfilePath_)
		If $hChk($sStaticJSONfilePath_) Then
			List()
		Else
			; Overrides Last used Carriage return @download func ,used display live progress.
			$hCout($sMessageConnectionError & @CRLF)
		EndIf
	EndIf
EndIf

; ______                    _                     _
; |  _  \                  | |                   | |
; | | | |_____      ___ __ | |     ___   __ _  __| |
; | | | / _ \ \ /\ / / '_ \| |    / _ \ / _` |/ _` |
; | |/ / (_) \ V  V /| | | | |___| (_) | (_| | (_| |
; |___/ \___/ \_/\_/ |_| |_\_____/\___/ \__,_|\__,_|
;
;
Func _dl($FileUrl, $stdoutMessage, $SavingdirandExt)
	If Not $hChk($sStaticJSONfilePath_) Then
		DirCreate($sPath2LocalDeirector)
	EndIf
	$_FileSize = InetGetSize($FileUrl)
	$_Download = InetGet($FileUrl, $SavingdirandExt, 1, 1)
	Local $_InfoData
	Do
		$_InfoData = InetGetInfo($_Download)
		If Not @error Then
			$_InetGet = $_InfoData[0]
			$_DownloadPercent = Round((100 * $_InetGet) / $_FileSize)
			$_DownloadPercent = _Min(_Max(1, $_DownloadPercent), 99)
			$hCout($stdoutMessage & " [" & $_DownloadPercent & "%]" & @CR)
		Else
			$hCout($sConnErrMessage & @CRLF)
			;TrayTip("Connection to server Error.", @ScriptName, 0, $TIP_ICONASTERISK)
		EndIf
		Sleep(20)
	Until $_InfoData[2] = True ; Or $_InfoData[$INET_DOWNLOADERROR]
	If $hChk($SavingdirandExt) Then
		; Successifuly downloaded Sets error to 0
		Return $hErr(0, 0, $hCout($stdoutMessage & " [100%]" & @CRLF))
	Else
		Return $hErr(1, 4, "0")
	EndIf
EndFunc   ;==>_dl

; Called after file exists
Func List()
	$hFileOpen = FileOpen($sStaticJSONfilePath_, $FO_READ)
	If $hFileOpen = -1 Then         ; Highly unlikely, but possible...
		Return $hErr(1, 400, $hCout( _
				"An error occurred when reading a database file." & @CRLF))
		Exit (@extended)
	EndIf
	$sProcessedObjects = FileRead($sStaticJSONfilePath_)
	$object = json_decode($sProcessedObjects)
	If @error = 1 Then         ; Also Highlt unlikely ,unless we change the attr from db.
		$hCout(" Err: Could not load necessary database file." & @CRLF)
		Exit
	EndIf
	FileClose($hFileOpen)
	; LoopThru all object keys to display the plugins available.
	Local $i = 0
	Local $sSearchCount = 1 ; Results for unspecified Searchname @ Param -list "Search String."
	Global $bFound = True
	While 1
		; ==========================================================================
		$asset_val = json_get($object, '[' & $i & ']' & '["name"]')
		$DirectDownloadLink = json_get($object, '[' & $i & ']' & '["html_url"]') & $sPrefixDownloadUrl
		$PluginDescription = json_get($object, '[' & $i & ']' & '["description"]')
		; ==========================================================================
		If @error Then ExitLoop 1     ; Reached EOF
		$index = $i + 1
		$sUsrRequest = _CmdLine_Get("list", "p")
		Switch $sUsrRequest
			Case "p"         ; for name to stdout.
				$hCout($index & ". " & $asset_val & @CRLF)         ; For debug
			Case "url"         ; for downloadlink.
				$hCout($index & ". " & $DirectDownloadLink & @CRLF)
			Case "des"         ; for description.
				$hCout($index & ". " & $PluginDescription & @CRLF)
			Case Else
				If $hSrchStr($asset_val, $sUsrRequest, 2) Then
					$bFound = True
					$hCout( _
							" > Found a match @Index :" & $index & @CRLF & _
							"   [ p  ] " & $asset_val & @CRLF & _
							"   [ des] " & $PluginDescription & @CRLF)
					$sSearchCount += 1
				Else
					$bFound = False
				EndIf
				; Search Plugin with specific name..
		EndSwitch
		; Sleep(20)
		$i += 1
	WEnd

	; If Not $bFound Then $hCout(" > " & $sUsrRequest & " Not found." & @CRLF)
	Exit (0)
EndFunc   ;==>List

Func Get()
	_dl($sStaticURLtoJSONfile, $sTablish, $sStaticJSONfilePath_)
	$hFileOpen = FileOpen($sStaticJSONfilePath_, $FO_READ)
	If $hFileOpen = -1 Then         ; Highly unlikely, but possible...
		$hCout("An error occurred when reading a necessary database file." & @CRLF)
		Exit (4)
	EndIf
	$sProcessedObjects = FileRead($sStaticJSONfilePath_)
	$object = json_decode($sProcessedObjects)
	If @error = 1 Then         ; Also Highlt unlikely ,unless we change the attr from db.
		$hCout(" Err: Could not load necessary database file." & @CRLF)
		Exit
	EndIf
	FileClose($hFileOpen)
	; loop thru all objects looking for the Plugin 'Key' Value..
	; MsgBox(0, '', $sProcessedObjects)
	Local $i = 0
	Global $asset_val, $PluginDescription, $DirectDownloadLink
	Global $bCanDownlod = False
	While 1
		; ==========================================================================
		$asset_val = json_get($object, '[' & $i & ']' & '["name"]')
		$DirectDownloadLink = json_get($object, '[' & $i & ']' & '["html_url"]') & $sPrefixDownloadUrl
		$PluginDescription = json_get($object, '[' & $i & ']' & '["description"]')
		; ==========================================================================
		$nIndex = $i
		If @error Then ExitLoop
		; $hCout("=======>> " & $DirectDownloadLink & @CRLF) ; For debug
		If $hSrchStr($asset_val, $sPluginName, $STR_NOCASESENSEBASIC) <> 0 Then         ; Also * Later adjust casesense
			$bCanDownlod = True
			ExitLoop
		EndIf
		;Sleep(20)
		$i += 1
	WEnd
	If $bCanDownlod Then
		$hCout( _
				" > " & $asset_val & @CRLF & _
				" > " & $PluginDescription & @CRLF & _
				" > geting Latest Commit For : " & $asset_val & @CRLF)         ;$DirectDownloadLink & @CRLF)
		Local $sFileOutPut = @ScriptDir & "\" & $asset_val & ".zip"
		_dl($DirectDownloadLink, " > Downloading " & $asset_val, $sFileOutPut)
		If $hChk($sFileOutPut) And _CmdLine_KeyExists("unzip") Then
			; $sExtractDir = _CmdLine_Get('unzip', @ScriptDir)
			$aListy = _ZipList($sFileOutPut)
			; _ArrayDisplay($aListy, "")
			$nTotalContents = UBound($aListy) - 1
			Local $sContentsActual = ""
			For $i = 1 To $nTotalContents
				$sContentsActual &= "    >> " & $aListy[$i] & @CRLF
			Next
			_ExtractZip($sFileOutPut, @ScriptDir)         ;$sExtractDir)
			If Not @error Then
				$hCout( _
						" > Extracted " & $nTotalContents & " root item(s) from " & $asset_val & ".zip" & @CRLF & _
						$sContentsActual & @CRLF)
			EndIf
		EndIf
	EndIf
EndFunc   ;==>Get

Func ByteSuffix($iBytes)
	Local $iIndex = 0, $aArray = [' bytes', ' KB', ' MB', ' GB', ' TB', ' PB', ' EB', ' ZB', ' YB']
	While $iBytes > 1023
		$iIndex += 1
		$iBytes /= 1024
	WEnd
	Return Round($iBytes) & $aArray[$iIndex]
EndFunc   ;==>ByteSuffix


;  _   _           _       _         ___                  _     _     _
; | | | |         | |     | |       |_  |                | |   (_)   | |
; | | | |_ __   __| | __ _| |_ ___    | | ___  ___  _ __ | |    _ ___| |_
; | | | | '_ \ / _` |/ _` | __/ _ \   | |/ __|/ _ \| '_ \| |   | / __| __|
; | |_| | |_) | (_| | (_| | ||  __/\__/ /\__ \ (_) | | | | |___| \__ \ |_
;  \___/| .__/ \__,_|\__,_|\__\___\____/ |___/\___/|_| |_\_____/_|___/\__| Saved For Later as an individual Param.
;       | |
;       |_|
Func UpdateJsonList($sSavingDirectory = @ScriptDir)
	$sCurrentNetworkConnection = IsConnected()
	If $sCurrentNetworkConnection Then
		; Connection is true... Download file from the internet.
		$hCout(@CRLF & _
				"Connection Status  : [200] [OK]" & @CRLF & _
				"Updating Database  : [...]" & @CRLF)
	Else
		; Connection is False Show errorcode....
		$hCout(@CRLF & _
				"Connection Status  : [0] [Failed]" & @CRLF & _
				"Internet Connection Error" & @CRLF)
		Exit (1)
	EndIf
EndFunc   ;==>UpdateJsonList


;_ExtractZip("C:\Users\$km\Desktop\New folder\Maps1.zip", "C:\Users\David\Desktop\New folder\maps")
; #FUNCTION# ;===============================================================================
;
; Name...........: _ExtractZip
; Description ...: Extracts file/folder from ZIP compressed file
; Syntax.........: _ExtractZip($sZipFile, $sDestinationFolder)
; Parameters ....: $sZipFile - full path to the ZIP file to process
;                  $sDestinationFolder - folder to extract to. Will be created if it does not exsist exist.
; Return values .: Success - Returns 1
;                          - Sets @error to 0
;                  Failure - Returns 0 sets @error:
;                  |1 - Shell Object creation failure
;                  |2 - Destination folder is unavailable
;                  |3 - Structure within ZIP file is wrong
;                  |4 - Specified file/folder to extract not existing
; Author ........: trancexx, modifyed by corgano
;  _____     _                  _   _______
; |  ___|   | |                | | |___  (_)
; | |____  _| |_ _ __ __ _  ___| |_   / / _ _ __
; |  __\ \/ / __| '__/ _` |/ __| __| / / | | '_ \
; | |___>  <| |_| | | (_| | (__| |_./ /__| | |_) |
; \____/_/\_\\__|_|  \__,_|\___|\__\_____/_| .__/
;                                          | |
;                                          |_|
;
Func _ExtractZip($sZipFile, $sDestinationFolder, $sFolderStructure = "")
	Local $i
	Do
		$i += 1
		$sTempZipFolder = @TempDir & "\Temporary Directory " & $i & " for " & $hRegexRp($sZipFile, ".*\\", "")
	Until Not $hChk($sTempZipFolder)         ; this folder will be created during extraction
	Local $oShell = ObjCreate("Shell.Application")
	If Not IsObj($oShell) Then
		Return $hErr(1, 0, 0)         ; highly unlikely but could happen
	EndIf
	Local $oDestinationFolder = $oShell.NameSpace($sDestinationFolder)
	If Not IsObj($oDestinationFolder) Then
		DirCreate($sDestinationFolder)
		; Return $hErr(2, 0, 0) ; unavailable destionation location
	EndIf
	Local $oOriginFolder = $oShell.NameSpace($sZipFile & "\" & $sFolderStructure)         ; FolderStructure is overstatement because of the available depth
	If Not IsObj($oOriginFolder) Then
		Return $hErr(3, 0, 0)         ; unavailable location
	EndIf
	Local $oOriginFile = $oOriginFolder.Items()         ;get all items
	If Not IsObj($oOriginFile) Then
		Return $hErr(4, 0, 0)         ; no such file in ZIP file
	EndIf
	; copy content of origin to destination
	$oDestinationFolder.CopyHere($oOriginFile, 20)         ; 20 means 4 and 16, replaces files if asked
	DirRemove($sTempZipFolder, 1)         ; clean temp dir
	Return 1         ; All OK!
EndFunc   ;==>_ExtractZip

Func IsConnected()
	Local Const $NETWORK_ALIVE_LAN = 0x1         ; net card connection
	Local Const $NETWORK_ALIVE_WAN = 0x2         ; RAS (internet) connection
	Local Const $NETWORK_ALIVE_AOL = 0x4         ; AOL
	Local $aRet, $iResult
	$aRet = DllCall("sensapi.dll", "int", "IsNetworkAlive", "int*", 0)
	If BitAND($aRet[1], $NETWORK_ALIVE_LAN) Then $iResult &= "LAN connected" & @LF
	If BitAND($aRet[1], $NETWORK_ALIVE_WAN) Then $iResult &= "WAN connected" & @LF
	If BitAND($aRet[1], $NETWORK_ALIVE_AOL) Then $iResult &= "AOL connected" & @LF
	Return $iResult
EndFunc   ;==>IsConnected


;  _____               _ _     _            _____      _
; /  __ \             | | |   (_)          |  __ \    | |
; | /  \/_ __ ___   __| | |    _ _ __   ___| |  \/ ___| |_
; | |   | '_ ` _ \ / _` | |   | | '_ \ / _ \ | __ / _ \ __|
; | \__/\ | | | | | (_| | |___| | | | |  __/ |_\ \  __/ |_
;  \____/_| |_| |_|\__,_\_____/_|_| |_|\___|\____/\___|\__|


Func _CmdLine_Get($sKey, $mDefault = Null)
	For $i = 1 To $CmdLine[0]
		If $CmdLine[$i] = "/" & $sKey Or $CmdLine[$i] = "-" & $sKey Or $CmdLine[$i] = "--" & $sKey Then
			If $CmdLine[0] >= $i + 1 Then
				Return $CmdLine[$i + 1]
			EndIf
		EndIf
	Next
	Return $mDefault
EndFunc   ;==>_CmdLine_Get

;  _____               _ _     _            _   __           _____     _     _
; /  __ \             | | |   (_)          | | / /          |  ___|   (_)   | |
; | /  \/_ __ ___   __| | |    _ _ __   ___| |/ /  ___ _   _| |____  ___ ___| |_ ___
; | |   | '_ ` _ \ / _` | |   | | '_ \ / _ \    \ / _ \ | | |  __\ \/ / / __| __/ __|
; | \__/\ | | | | | (_| | |___| | | | |  __/ |\  \  __/ |_| | |___>  <| \__ \ |_\__ \
;  \____/_| |_| |_|\__,_\_____/_|_| |_|\___\_| \_/\___|\__, \____/_/\_\_|___/\__|___/
;                                                       __/ |
;                                                      |___/
Func _CmdLine_KeyExists($sKey)
	For $i = 1 To $CmdLine[0]
		If $CmdLine[$i] = "/" & $sKey Or $CmdLine[$i] = "-" & $sKey Or $CmdLine[$i] = "--" & $sKey Then
			Return True
		EndIf
	Next
	Return False
EndFunc   ;==>_CmdLine_KeyExists

;  _____               _ _     _             _   _       _            _____     _     _
; /  __ \             | | |   (_)           | | | |     | |          |  ___|   (_)   | |
; | /  \/_ __ ___   __| | |    _ _ __   ___ | | | | __ _| |_   _  ___| |____  ___ ___| |_ ___
; | |   | '_ ` _ \ / _` | |   | | '_ \ / _ \| | | |/ _` | | | | |/ _ \  __\ \/ / / __| __/ __|
; | \__/\ | | | | | (_| | |___| | | | |  __/\ \_/ / (_| | | |_| |  __/ |___>  <| \__ \ |_\__ \
;  \____/_| |_| |_|\__,_\_____/_|_| |_|\___| \___/ \__,_|_|\__,_|\___\____/_/\_\_|___/\__|___/


Func _CmdLine_ValueExists($sValue)
	For $i = 1 To $CmdLine[0]
		If $CmdLine[$i] = $sValue Then
			Return True
		EndIf
	Next
	Return False
EndFunc   ;==>_CmdLine_ValueExists

;  _____               _ _     _             ______ _             _____            _     _          _
; /  __ \             | | |   (_)            |  ___| |           |  ___|          | |   | |        | |
; | /  \/_ __ ___   __| | |    _ _ __   ___  | |_  | | __ _  __ _| |__ _ __   __ _| |__ | | ___  __| |
; | |   | '_ ` _ \ / _` | |   | | '_ \ / _ \ |  _| | |/ _` |/ _` |  __| '_ \ / _` | '_ \| |/ _ \/ _` |
; | \__/\ | | | | | (_| | |___| | | | |  __/ | |   | | (_| | (_| | |__| | | | (_| | |_) | |  __/ (_| |
;  \____/_| |_| |_|\__,_\_____/_|_| |_|\___| \_|   |_|\__,_|\__, \____/_| |_|\__,_|_.__/|_|\___|\__,_|
;                                        ______              __/ |
;                                       |______|            |___/
Func _CmdLine_FlagEnabled($sKey)
	For $i = 1 To $CmdLine[0]
		If $hRegeX($CmdLine[$i], "\+([a-zA-Z]*)" & $sKey & "([a-zA-Z]*)") Then
			Return True
		EndIf
	Next
	Return False
EndFunc   ;==>_CmdLine_FlagEnabled

;  _____               _ _     _             ______ _            ______ _           _     _          _
; /  __ \             | | |   (_)            |  ___| |           |  _  (_)         | |   | |        | |
; | /  \/_ __ ___   __| | |    _ _ __   ___  | |_  | | __ _  __ _| | | |_ ___  __ _| |__ | | ___  __| |
; | |   | '_ ` _ \ / _` | |   | | '_ \ / _ \ |  _| | |/ _` |/ _` | | | | / __|/ _` | '_ \| |/ _ \/ _` |
; | \__/\ | | | | | (_| | |___| | | | |  __/ | |   | | (_| | (_| | |/ /| \__ \ (_| | |_) | |  __/ (_| |
;  \____/_| |_| |_|\__,_\_____/_|_| |_|\___| \_|   |_|\__,_|\__, |___/ |_|___/\__,_|_.__/|_|\___|\__,_|
;                                        ______              __/ |
;                                       |______|            |___/

Func _CmdLine_FlagDisabled($sKey)
	For $i = 1 To $CmdLine[0]
		If $hRegeX($CmdLine[$i], "\-([a-zA-Z]*)" & $sKey & "([a-zA-Z]*)") Then
			Return True
		EndIf
	Next
	Return False
EndFunc   ;==>_CmdLine_FlagDisabled

;  _____               _ _     _             ______ _             _____     _     _
; /  __ \             | | |   (_)            |  ___| |           |  ___|   (_)   | |
; | /  \/_ __ ___   __| | |    _ _ __   ___  | |_  | | __ _  __ _| |____  ___ ___| |_ ___
; | |   | '_ ` _ \ / _` | |   | | '_ \ / _ \ |  _| | |/ _` |/ _` |  __\ \/ / / __| __/ __|
; | \__/\ | | | | | (_| | |___| | | | |  __/ | |   | | (_| | (_| | |___>  <| \__ \ |_\__ \
;  \____/_| |_| |_|\__,_\_____/_|_| |_|\___| \_|   |_|\__,_|\__, \____/_/\_\_|___/\__|___/
;                                        ______              __/ |
;                                       |______|            |___/
Func _CmdLine_FlagExists($sKey)
	For $i = 1 To $CmdLine[0]
		If $hRegeX($CmdLine[$i], "(\+|\-)([a-zA-Z]*)" & $sKey & "([a-zA-Z]*)") Then
			Return True
		EndIf
	Next
	Return False
EndFunc   ;==>_CmdLine_FlagExists


;  _____               _ _     _             _____      _   _   _       _______      _____          _
; /  __ \             | | |   (_)           |  __ \    | | | | | |     | | ___ \    |_   _|        | |
; | /  \/_ __ ___   __| | |    _ _ __   ___ | |  \/ ___| |_| | | | __ _| | |_/ /_   _ | | _ __   __| | _____  __
; | |   | '_ ` _ \ / _` | |   | | '_ \ / _ \| | __ / _ \ __| | | |/ _` | | ___ \ | | || || '_ \ / _` |/ _ \ \/ /
; | \__/\ | | | | | (_| | |___| | | | |  __/| |_\ \  __/ |_\ \_/ / (_| | | |_/ / |_| || || | | | (_| |  __/>  <
;  \____/_| |_| |_|\__,_\_____/_|_| |_|\___| \____/\___|\__|\___/ \__,_|_\____/ \__, \___/_| |_|\__,_|\___/_/\_\
;                                        ______                                  __/ |
;                                       |______|                                |___/

Func _CmdLine_GetValByIndex($iIndex, $mDefault = Null)
	If $CmdLine[0] >= $iIndex Then
		Return $CmdLine[$iIndex]
	Else
		Return $mDefault
	EndIf
EndFunc   ;==>_CmdLine_GetValByIndex

#comments-start
=======================================================================================
     _____      ___             _ _     _ _   _______ _
    |_   _|    / _ \           | (_)   | | | | | ___ \ |
      | | ___ / /_\ \_   ____ _| |_  __| | | | | |_/ / |
      | |/ __||  _  \ \ / / _` | | |/ _` | | | |    /| |
     _| |\__ \| | | |\ V / (_| | | | (_| | |_| | |\ \| |____
     \___/___/\_| |_/ \_/ \__,_|_|_|\__,_|\___/\_| \_\_____/
 ______
|______|

Func Validate target URL:
We want to promote development so we can allow a user to use our program to work with
his own JSON data, So this function will test If the Parsed URL resolves to an actual File
Hosted on a site.
=======================================================================================
#comments-end  
Func _IsAvalidURL($sURL)
	If _WinAPI_UrlIs($sURL, $URLIS_FILEURL) Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>_IsAvalidURL

Func _ZipCreate($sZip)
	If Not StringLen(Chr(0)) Then Return $hErr(1)
	Local $sHeader = Chr(80) & Chr(75) & Chr(5) & Chr(6), $hFile
	For $i = 1 To 18
		$sHeader &= Chr(0)
	Next
	$hFile = FileOpen($sZip, 2)
	FileWrite($hFile, $sHeader)
	FileClose($hFile)
EndFunc   ;==>_ZipCreate

Func _ZipAdd($sZip, $sFile)
	If Not StringLen(Chr(0)) Then Return $hErr(1)
	If Not $hChk($sZip) Or Not $hChk($sFile) Then Return $hErr(2)
	Local $oShell = ObjCreate('Shell.Application')
	If @error Or Not IsObj($oShell) Then Return $hErr(3)
	Local $oFolder = $oShell.NameSpace($sZip)
	If @error Or Not IsObj($oFolder) Then Return $hErr(4)
	$oFolder.CopyHere($sFile)
	Sleep(500)
EndFunc   ;==>_ZipAdd

Func _ZipList($sZip)
	If Not StringLen(Chr(0)) Then Return $hErr(1)
	If Not $hChk($sZip) Then Return $hErr(2)
	Local $oShell = ObjCreate('Shell.Application')
	If @error Or Not IsObj($oShell) Then Return $hErr(3)
	Local $oFolder = $oShell.NameSpace($sZip)
	If @error Or Not IsObj($oFolder) Then Return $hErr(4)
	Local $oItems = $oFolder.Items()
	If @error Or Not IsObj($oItems) Then Return $hErr(5)
	Local $i = 0
	For $o In $oItems
		$i += 1
	Next
	Local $aNames[$i + 1]
	$aNames[0] = $i
	$i = 0
	For $o In $oItems
		$i += 1
		$aNames[$i] = $oFolder.GetDetailsOf($o, 0)
	Next
	Return $aNames
EndFunc   ;==>_ZipList

; _ZipCreate(@ScriptDir & "\test.zip")
; _ZipAdd(@ScriptDir & "\test.zip", @ScriptFullPath)
; $list = _ZipList(@ScriptDir & "\test.zip")
; For $i = 0 to UBound($list, 1) - 1
;     MsgBox(0, '[' & $i & ']', $list[$i])
; Next

Exit (0)