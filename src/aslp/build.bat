@echo off

setlocal

taskkill /F /IM "svencoop.exe"

if not exist bin (
    mkdir bin
    cd bin
    cmake -A Win32 ..
    cd ..
)

cmake --build bin --config Release --clean-first

if %ERRORLEVEL% NEQ 0 (
    echo ERROR
    pause
    exit /b %ERRORLEVEL%
)

set "SourceFile=C:\Users\Usuario\Documents\GitHub\Sven-Co-op\src\aslp\bin\Release\aslp.dll"
set "DestinationDir=C:\Program Files (x86)\Steam\steamapps\common\Sven Co-op\svencoop\addons\metamod\dlls\aslp.dll"
copy "%SourceFile%" "%DestinationDir%" /Y
echo "Installed to %SourceFile%"

"C:\Users\Usuario\Desktop\Sven Co-op.url"

pause
