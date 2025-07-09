@echo off
chcp 65001 >nul

set "connected=false"
set "miniWorldPath="

:menu
cls
echo ==============================
echo        MReplace Menu
echo ==============================
echo [ 1 ] Inject
echo [ 2 ] MovePNG
echo [ 3 ] Replace
echo [ 4 ] Exit
echo.
if "%connected%"=="true" (
    echo Status: Connected
) else (
    echo Status: Not Connected
)
echo.
set /p choice= Pilih opsi: 
if "%choice%"=="1" goto inject
if "%choice%"=="2" goto mv
if "%choice%"=="3" goto replace
if "%choice%"=="4" exit
echo Pilihan tidak valid!
pause
goto menu

:mv
cls
echo --------------------------------------
echo   Move Thumb.png
echo                                       
echo --------------------------------------
set /p "Press Enter"

echo.
echo Conecting...
for /f "usebackq tokens=*" %%i in (`powershell -NoProfile -Command "(New-Object -ComObject WScript.Shell).CreateShortcut('%shortcutFile%').TargetPath"`) do set "targetPath=%%i"
echo Conected Path: %targetPath%

rem Naik dua level ke atas dari target path
for %%a in ("%targetPath%\..\..") do set "baseDir=%%~fa"
echo PV Path: %baseDir%

rem Pastikan folder miniworddata410 ada di baseDir
if not exist "%baseDir%\miniworddata410" (
    echo Folder miniworddata410 Not Found In %baseDir%.
    pause
    goto menu
)

set "dataPath=%baseDir%\miniworddata410\data"
if not exist "%dataPath%" (
    echo Folder Not Found In %baseDir%\miniworddata410.
    pause
    goto menu
)

echo.
echo Finding Folder...
timeout /t 2 >nul

rem Membuat folder tujuan di Desktop
set "destFolder=%USERPROFILE%\Desktop\MReplacer"
if not exist "%destFolder%" mkdir "%destFolder%"

set count=0
for /d %%F in ("%dataPath%\w??????????????") do (
    set "folderName=%%~nxF"
    call :processFolder "%%F" "%%~nxF"
)

if %count%==0 (
    echo Folder Path Is Invalid
) else (
    echo Done %count% folder.
    set "connected=true"
    set "miniWorldPath=%baseDir%\miniworddata410"
)
pause
goto menu

:processFolder
rem Parameter: %1 = full folder path, %2 = folder name
setlocal EnableDelayedExpansion
set "folderPath=%~1"
set "folderName=%~2"
if exist "!folderPath!\thumb.png_" (
    echo Found thumb.png_ in folder !folderName!
    rem Salin dan ganti nama file sesuai dengan nama folder (format .png)
    copy "!folderPath!\thumb.png_" "%destFolder%\!folderName!.png" /Y >nul
    echo file has been copied  !folderName!.png
    rem Menambahkan log dengan tanggal pembuatan folder
    for /f "tokens=1,2 delims==" %%a in ('"dir /T:C !folderPath! | findstr /i /c:"!folderName!" "') do echo !folderName! - %%a %%b >> "%destFolder%\log.txt"
    set /a count+=1
) else (
    echo File thumb.png_ not found in !folderName!
)
endlocal
goto :eof

:inject
cls
echo ==============================
echo         Inject Menu
echo ==============================
echo [ 1 ] Auto
echo [ 2 ] Manual
echo.

set /p injectChoice= Pilih opsi: 
if "%injectChoice%"=="1" goto injectAuto
if "%injectChoice%"=="2" goto injectManual
echo input is invalid
pause
goto inject

:injectAuto
rem Mencari shortcut Mini World di Desktop
set "shortcutFile=%USERPROFILE%\Desktop\Mini World.lnk"
if exist "%shortcutFile%" (
    echo Ditemukan shortcut Mini World di Desktop.
    call :processStart "%shortcutFile%"
    goto menu
) else (
    echo Shortcut is not found. please drag Mini World shortcut to cmd.
    pause
    goto injectManual
)

:injectManual
cls
echo --------------------------------------
echo   Drag and Drop shortcut Mini World ke sini
echo   (contoh: E:\Mini World\miniworldOverseasgame.lnk)
echo --------------------------------------
set /p "shortcutFile=Insert shortcut path: "
call :processStart "%shortcutFile%"
goto menu

:processStart
rem Proses yang sama seperti menu start, hanya dengan pengaturan path otomatis
set "shortcutFile=%~1"
echo Get target path from shortcut...
for /f "usebackq tokens=*" %%i in (`powershell -NoProfile -Command "(New-Object -ComObject WScript.Shell).CreateShortcut('%shortcutFile%').TargetPath"`) do set "targetPath=%%i"
echo Target path: %targetPath%

rem Naik dua level ke atas dari target path
for %%a in ("%targetPath%\..\..") do set "baseDir=%%~fa"
echo Base folder: %baseDir%

rem Pastikan folder miniworddata410 ada di baseDir
if not exist "%baseDir%\miniworddata410" (
    echo Miniworddata410 folder not found in %baseDir%.
    pause
    goto menu
)

set "dataPath=%baseDir%\miniworddata410\data"
if not exist "%dataPath%" (
    echo folder data not found in %baseDir%\miniworddata410.
    pause
    goto menu
)

set "connected=true"
set "miniWorldPath=%baseDir%\miniworddata410"
echo Inject Done!
pause
goto menu

:replace
cls
echo ==============================
echo          Replace
echo ==============================
echo.
echo Option:
echo [ 1 ] Selected 
echo [ 2 ] Manual
echo.

set /p replaceChoice= Pilih opsi: 
if "%replaceChoice%"=="1" goto replaceSelected
if "%replaceChoice%"=="2" goto replaceManual
echo input is invalid!
pause
goto replace

:replaceSelected
cls
setlocal EnableDelayedExpansion
set /a count=0
set "folderList="

echo ==============================
echo       Pilih Folder Original
echo ==============================

rem Menampilkan daftar folder dengan nomor urut
for /d %%F in ("%miniWorldPath%\data\w??????????????") do (
    set /a count+=1
    set "folderList[!count!]=%%~nxF"
    echo [!count!] = %%~nxF
)

if %count%==0 (
    echo Tidak ada folder yang ditemukan!
    pause
    goto replace
)

echo.
set /p folderNumber=Masukkan nomor folder untuk Map Original: 

rem Validasi input angka
if not defined folderList[%folderNumber%] (
    echo Pilihan tidak valid!
    pause
    goto replaceSelected
)

set "originalFolder=!folderList[%folderNumber%]!"
set "originalFolderPath=%miniWorldPath%\data\%originalFolder%"
echo Folder Original dipilih: %originalFolderPath%

rem Pilih Map Patched dengan sistem yang sama
cls
set /a count=0
echo ==============================
echo       Pilih Folder Patched
echo ==============================

rem Menampilkan daftar folder dengan nomor urut
for /d %%F in ("%miniWorldPath%\data\w??????????????") do (
    set /a count+=1
    set "folderList[!count!]=%%~nxF"
    echo [!count!] = %%~nxF
)

echo.
set /p folderNumber=Masukkan nomor folder untuk Map Patched: 

rem Validasi input angka
if not defined folderList[%folderNumber%] (
    echo Pilihan tidak valid!
    pause
    goto replaceSelected
)

set "patchedFolder=!folderList[%folderNumber%]!"
set "patchedFolderPath=%miniWorldPath%\data\%patchedFolder%"
echo Folder Patched dipilih: %patchedFolderPath%

rem Validasi folder
if not exist "%originalFolderPath%" (
    echo Folder Map Original tidak ditemukan: %originalFolderPath%
    pause
    goto replace
)
if not exist "%patchedFolderPath%" (
    echo Folder Map Patched tidak ditemukan: %patchedFolderPath%
    pause
    goto replace
)
if not exist "%patchedFolderPath%\customui" (
    echo Folder "customui" tidak ditemukan di Map Patched.
    pause
    goto replace
)
if not exist "%patchedFolderPath%\ss" (
    echo Folder "ss" tidak ditemukan di Map Patched.
    pause
    goto replace
)

rem Proses Copy
echo Menyalin folder "customui" dan "ss" dari Map Patched ke Map Original...
xcopy "%patchedFolderPath%\customui" "%originalFolderPath%\customui" /E /I /H /Y >nul
xcopy "%patchedFolderPath%\ss" "%originalFolderPath%\ss" /E /I /H /Y >nul
echo Proses selesai.
pause
goto menu




:replaceManual
cls
echo ==============================
echo       Fitur Replace
echo ==============================
echo.

cls
set /p "mapOriginal=Masukkan nama folder Map Original: "
set /p "mapPatched=Masukkan nama folder Map Patched: "
set "originalFolder=%dataPath%\%mapOriginal%"
set "patchedFolder=%dataPath%\%mapPatched%"
if not exist "%originalFolder%" (
    echo Folder Map Original tidak ditemukan.
    pause
    goto menu
)
if not exist "%patchedFolder%" (
    echo Folder Map Patched tidak ditemukan.
    pause
    goto menu
)
if not exist "%patchedFolder%\customui" (
    echo Folder "customui" tidak ditemukan di Map Patched.
    pause
    goto menu
)
if not exist "%patchedFolder%\ss" (
    echo Folder "ss" tidak ditemukan di Map Patched.
    pause
    goto menu
)

echo Menyalin folder "customui" dan "ss" dari Map Patched ke Map Original...
xcopy "%patchedFolder%\customui" "%originalFolder%\customui" /E /I /H /Y >nul
xcopy "%patchedFolder%\ss" "%originalFolder%\ss" /E /I /H /Y >nul
echo Proses selesai.
pause
goto menu