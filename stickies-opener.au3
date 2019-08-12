#include <File.au3>
#include <MsgBoxConstants.au3>
#include <FileConstants.au3>
#include <WinAPIFiles.au3>
#include <Array.au3>
#pragma compile(Icon, 'stickies.ico')

; --------------------------------

Func GetFileName($sFilePath)
   If Not IsString($sFilePath) Then
	 Return SetError(1, 0, -1)
   EndIf

   Local $FileName = StringRegExpReplace($sFilePath, "^.*\\", "")

   Return $FileName
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
   Local $stiFilename = $file & '.sti'
   Local $hWriteFileOpen = FileOpen($stiFilename, $FO_OVERWRITE + $FO_UTF16_LE)

   If $hWriteFileOpen = -1 Then
		MsgBox($MB_SYSTEMMODAL, "", "An error occurred whilst writing the temporary file.")
		Return False
	 EndIf

   FileWrite($hWriteFileOpen, $sti)
   FileClose($hWriteFileOpen)

   ; ------------------------------
   Local $cmd = '"' & @ScriptDir & '\Stickies\stickies.exe" "' & $stiFilename & '"'

   ;MsgBox($MB_SYSTEMMODAL, $title, $cmd)
   Run($cmd)

   ; ------------------------------
   Sleep(1000)
   FileDelete($stiFilename)
Next