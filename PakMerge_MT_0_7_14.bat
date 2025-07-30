@echo off
setlocal enabledelayedexpansion

set "AES_KEY=0xD9633F9140D5494AE4A469BDA384896BD1B9644D50D281E64ECFF4900B8E8E80"

set "BASE_PAK="
for %%f in (*.pak) do (
    echo %%~nxf | findstr /I "_P" >nul
    if errorlevel 1 (
        set "BASE_PAK=%%~nxf"
    )
)

if not defined BASE_PAK (
    echo Error: No base .pak file found!
    exit /b 1
)

echo Base .pak found: %BASE_PAK%

repak.exe -a %AES_KEY% unpack "%BASE_PAK%"
set "BASE_FOLDER=%BASE_PAK:.pak=%"

del /q "%BASE_PAK%"

echo Processing .pak files to remove all underscores...
for %%F in (*.pak) do (
    set "filename=%%F"
    
    echo !filename! | findstr /C:"_" >nul
    if !errorlevel! equ 0 (
        set "newname=!filename:_=!"
        
        if not "!newname!"=="%%F" (
            if exist "!newname!" (
                echo   WARNING: Target file "!newname!" already exists! Skipping %%F
            ) else (
                ren "%%F" "!newname!"
                echo   Renamed: %%F to !newname!
            )
        )
    ) else (
        echo   No underscores found in: %%F
    )
)

echo.
echo Step 2: Adding underscores to P.pak files...
for %%F in (*P.pak) do (
    set "filename=%%F"
    echo !filename! | findstr /E "_P.pak" >nul
    if !errorlevel! neq 0 (
        set "newname=!filename:P.pak=_P.pak!"
        if not "!newname!"=="%%F" (
            ren "%%F" "!newname!"
            echo   Renamed: %%F to !newname!
        )
    )
)

for %%f in (*_P.pak) do (
    echo Unpacking: %%f
    repak.exe unpack "%%f"
    del /q "%%f"
)

for /f %%d in ('dir /b /ad /o:n *_P') do (
    echo Merging folder: %%d -> %BASE_FOLDER%
    xcopy "%%d\*" "%BASE_FOLDER%\" /E /H /Y
)

for /d %%d in (*) do (
    if /i not "%%d"=="%BASE_FOLDER%" (
        echo Removing folder: %%d
        rd /s /q "%%d"
    )
)

repak.exe -a %AES_KEY% pack "%BASE_FOLDER%"
rd /s /q "%BASE_FOLDER%"

echo.
echo ✅ Mod merge complete inside the base files
echo You may now run the game!
pause
