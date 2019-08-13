#include <File.au3>
#include <MsgBoxConstants.au3>
#include <FileConstants.au3>
#include <WinAPIFiles.au3>
#include <Array.au3>
#Include <WinAPI.au3>
#include <Date.au3>
#include <String.au3>
#pragma compile(Icon, 'stickies.ico')
Global Const $CP_UTF8 = 65001
; --------------------------------

Func GetFileName($sFilePath)
   If Not IsString($sFilePath) Then
	 Return SetError(1, 0, -1)
   EndIf

   Local $FileName = StringRegExpReplace($sFilePath, "^.*\\", "")

   Return $FileName
EndFunc

Func openWithStickies($file, $sti)
   Local $stiFilename = $file & '.sti'
   ;$stiFilename = StringReplace($stiFilename, ":", "-")

   Local $hWriteFileOpen = FileOpen($stiFilename, $FO_OVERWRITE + $FO_UTF16_LE)

   If $hWriteFileOpen = -1 Then
		MsgBox($MB_SYSTEMMODAL, $stiFilename, "An error occurred whilst writing the temporary file." & @CRLF & $stiFilename)
		Return False
	 EndIf

   FileWrite($hWriteFileOpen, $sti)
   FileClose($hWriteFileOpen)

   ; ------------------------------
   If ProcessExists("stickies.exe") = False Then ; Check if the Notepad process is running.
	  Run('"' & @ScriptDir & '\Stickies\stickies.exe"')
	  Sleep(500)
   EndIf

   ; ------------------------------
   Local $cmd = '"' & @ScriptDir & '\Stickies\stickies.exe" "' & $stiFilename & '"'

   ;MsgBox($MB_SYSTEMMODAL, $title, $cmd)
   Run($cmd)

   ; ------------------------------
   Sleep(1000)
   FileDelete($stiFilename)
EndFunc

Func StringTrim($str)
   return StringStripWS($str,  $STR_STRIPLEADING + $STR_STRIPTRAILING )
EndFunc

Func _convertUnicode($string)

   Local $char

   Local $code
   Local $codes = ''

   For $i = 1 to StringLen($string)

	  $char = StringMid($string, $i, 1)

	  $code = Asc($char)

	  If $code > 127 Then
		 $code = $code * 256
		 $i = $i + 1
		 $char = StringMid($string, $i, 1)
		 $code = $code + Asc($char)
	  EndIf
	  $codes = $codes & "\'" & $code
   Next
   Return $codes

EndFunc

; --------------------------------

For $i = 1 To $CmdLine[0]
   Local $file = $CmdLine[$i]

   Local $title = GetFileName($file)

   ; ------------------------------------
   ; Create a sti file from file
   Local $hFileOpen = FileOpen($file, $FO_READ)
   If $hFileOpen = -1 Then
        MsgBox($MB_SYSTEMMODAL, "", "An error occurred when reading the file.")
        Return False
	 EndIf


    ; Read the contents of the file using the handle returned by FileOpen.
    Local $sFileRead = FileRead($hFileOpen)

    ; Close the handle returned by FileOpen.
    FileClose($hFileOpen)

   ;MsgBox($MB_SYSTEMMODAL, $title, $sFileRead)

   ; ------------------------------------
   ; Mockup sti file
   Local $sti = 'col: 255,255,180' & @CRLF & 'title: ' & $title  & @CRLF & @CRLF
   ;$sti = $sti & @CRLF & '{\rtf1\ansi\ansicpg950\deff0\deflang1033\deflangfe1028{\fonttbl{\f0\fswiss\fcharset0 Arial;}{\f1\fswiss\fprq2\fcharset128 Noto Sans CJK TC Regular;}}'
   ;$sti = $sti & @CRLF & '{\colortbl ;\red0\green0\blue0;}'
   ;$sti = $sti & @CRLF & '{\*\generator Msftedit 5.41.21.2510;}\viewkind4\uc1\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\tx9360\tx10080\tx10800\tx11520\tx12240\tx12960\tx13680\tx14400\tx15120\tx15840\tx16560\tx17280\tx18000\tx18720\tx19440\tx20160\tx20880\tx21600\tx22320\tx23040\cf1\lang1041\f0\fs29 '
   ;$sti = $sti & StringReplace($sFileRead, @CRLF, '\par' & @CRLF) & '\lang1041\f1\par'
   ;$sti = $sti & @CRLF & '}'

   $sti = $sti & $sFileRead

   ;MsgBox($MB_SYSTEMMODAL, $title, $sti)

   ; -------------------------------------
   ; Write sti file
   openWithStickies($file, $sti)
Next

; ---------------------------------------

If $CmdLine[0] = 0 Then
   Local $sData = ClipGet()
   ;$sData = '附件四作業要點'
   ;MsgBox($MB_SYSTEMMODAL, "sData", $sData & '')
   If $sData <> 1 And $sData <> 2 And $sData <> 3 And $sData <> 4 Then

	  ;$sData = _WinAPI_WideCharToMultiByte($CP_UTF8, $sData)
	  ;$sData = BinaryToString(StringToBinary($sData), 4)
	  ;$sData = Execute(StringRegExpReplace($sData, '(.)', '(AscW("$1")>127?"\\u"&StringLower(Hex(AscW("$1"),4)):"$1")&') & "''")
	  ;$sData = Execute("'" & StringRegExpReplace($sData, "(\\u([[:xdigit:]]{4}))","' & ChrW(0x$2) & '") & "'")
	  ;$sData = Execute("'" & StringRegExpReplace($sData, "(\\u([[:xdigit:]]{2})([[:xdigit:]]{2}))","' & Chr(0x30  + 0x$3) & '") & "'")
	  ;$sData = _convertUnicode($sData)
	  ;$sData = StringToASCIIArray($sData, 0, StringLen($sData), 2)

	  $sData = StringReplace($sData, @CRLF, @CR)
	  $sData = StringTrim($sData)
	  Local $titleAbsctract = $sData

	  Local $sHex =  StringToBinary($sData, 1)
	  Local $sEscaped = StringRegExpReplace(StringMid($sHex, 3), '([[:xdigit:]]{2})', 'x$1')
	  $sData = StringReplace($sEscaped, 'x', "\'")
	  ;$sData = Hex($sData, 2)
	  ;MsgBox($MB_SYSTEMMODAL, "utf8", $sEscaped)
	  ;Exit

	  ;MsgBox($MB_SYSTEMMODAL, "Pc Long format", _DateTimeFormat(_NowCalc(), 1))
	  Local $title = "Clip " & _DateTimeFormat(_NowCalc(), 5)


	  $titleAbsctract = StringReplace($titleAbsctract, @CR, ' ')
	  If StringLen($titleAbsctract) > 15 Then
		$titleAbsctract = StringMid($titleAbsctract, 1, 15) & '...'
	  EndIf
	  Local $stickyTitle = '[' & _DateTimeFormat(_NowCalc(), 5) & '] ' & $titleAbsctract

	  ;MsgBox($MB_SYSTEMMODAL, "format 5", $title)
	  $title = StringReplace($title, "'", "")
	  Local $sti = 'col: 255,255,180' & @CRLF & 'title: ' & $stickyTitle  & @CRLF & @CRLF
	  ;$sti = $sti & $sData

	  $sti = $sti & "{\rtf1\ansi\ansicpg950\deff0\deflang1033\deflangfe1028{\fonttbl{\f0\fswiss\fprq2\fcharset136 System;}}"
	  $sti = $sti & @CRLF & "{\*\generator Msftedit 5.41.21.2510;}\viewkind4\uc1\pard\lang1028\b\f0\fs24 "
	  $sti = $sti & $sData
	  $sti = $sti & @CRLF & "}"

	  $title = StringReplace($title, ":", "-")
	  openWithStickies($title, $sti)
   EndIf
EndIf