@echo off

setlocal

if not exist bin (
    mkdir bin
    cd bin
    cmake -A Win32 ..
    cd ..
)

cmake --build bin --config Debug --clean-first

if %ERRORLEVEL% NEQ 0 (
    echo ERROR
    pause
    exit /b %ERRORLEVEL%
)

cd bin
cd Debug

set "LibCurl=C:\Program Files (x86)\Steam\steamapps\common\Sven Co-op\libcurl.dll"
copy "%LibCurl%" "%CD%" /Y

main.exe

pause
