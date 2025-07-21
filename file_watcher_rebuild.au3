; ========== KONFIG ==========

Global Const $watchFolder  = "C:\Users\pl70008930\OneDrive - Friedhelm Loh Group\Dokumenty\AutoIT\Test sprawdzenia pliku"
Global Const $uploadFolder = "C:\Program Files\EPLAN\EPLAN Smart Production Collection 2024\server\swa\storage\Uploaded"
Global Const $seleniumExe  = "C:\Users\pl70008930\source\repos\.NET\SmartProductionLogin\bin\Release\net6.0\publish\SmartProductionLogin.exe"

; ========== LISTA ZNANYCH [plik, czas_modyfikacji] ==========

Global $known[1][2] = [["", ""]] ; wiersz 0 pusty

; ========== INICJALIZACJA ==========

Local $existing = _InitKnown() ; zwraca tablice plików istniejacych

If UBound($existing) > 0 Then
	Local $resp = MsgBox(36, "Istniejace pliki", _
    "Znaleziono " & UBound($existing) & " plik/ów .epdz w folderze." & @CRLF & _
    "Czy chcesz je teraz przetworzyc (utworzyc zamówienia)?")

    ; 6 = Yes, 7 = No
    If $resp = 6 Then
        For $i = 0 To UBound($existing) - 1
            _ProcessFile($existing[$i][0], $existing[$i][1])
        Next
    EndIf
EndIf

ConsoleWrite("Watcher startuje…" & @CRLF)

; ========== PETLA GLÓWNA ==========

While 1
    Sleep(3000)

    Local $search = FileFindFirstFile($watchFolder & "\*.epdz")
    If $search = -1 Then ContinueLoop

    While 1
        Local $file = FileFindNextFile($search)
        If @error Then ExitLoop

        Local $src  = $watchFolder & "\" & $file
        Local $time = FileGetTime($src, 0, 1) ; YYYYMMDDhhmmss

        If Not _IsKnown($file, $time) Then
            _Add($file, $time)
            _ProcessFile($file, $time)
        EndIf
    WEnd
    FileClose($search)
WEnd

; ========== FUNKCJE ==========

; -- inicjalizacja listy znanych oraz zwrot tablicy istniejacych plików --
Func _InitKnown()
    Local $arr[0][2]
    Local $h = FileFindFirstFile($watchFolder & "\*.epdz")
    If $h = -1 Then Return $arr

    While 1
        Local $f = FileFindNextFile($h)
        If @error Then ExitLoop
        Local $t = FileGetTime($watchFolder & "\" & $f, 0, 1)
        _Add($f, $t)

        ReDim $arr[UBound($arr) + 1][2]
        $arr[UBound($arr) - 1][0] = $f
        $arr[UBound($arr) - 1][1] = $t
    WEnd
    FileClose($h)
    Return $arr
EndFunc

; -- proces pojedynczego pliku (.epdz) --
Func _ProcessFile($name, $time)
    Local $src  = $watchFolder & "\" & $name
    Local $dest = $uploadFolder & "\" & $name

    FileCopy($src, $dest, 9) ; overwrite
    ConsoleWrite("Wykryto i przekazano: " & $name & " [" & $time & "]" & @CRLF)

    Local $cmd = '"' & $seleniumExe & '" "' & $dest & '"'
    Run($cmd, "", @SW_HIDE)

    ; --- dzwiek + popup 5 s ---
    Beep(1000, 200)
    Local $msg = "Wszystko wykonano pomyslnie." & @CRLF & _
                 "Pozdrawiam – Darek Tkaczuk life4more.pl"
    MsgBox(BitOR(64, 4096), "Status", $msg, 5)
EndFunc

; -- sprawdzenie, czy nazwa + data juz znane --
Func _IsKnown($name, $time)
    For $i = 1 To UBound($known) - 1
        If $known[$i][0] = $name And $known[$i][1] = $time Then Return True
    Next
    Return False
EndFunc

; -- dopisz do listy znanych --
Func _Add($name, $time)
    ReDim $known[UBound($known) + 1][2]
    $known[UBound($known) - 1][0] = $name
    $known[UBound($known) - 1][1] = $time
EndFunc
