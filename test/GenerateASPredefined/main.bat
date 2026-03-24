@echo off

setlocal

if not exist bin (
    cmake -S . -B bin -G "Visual Studio 16 2019" -A Win32
)

cmake --build bin --config Debug --clean-first

if %ERRORLEVEL% NEQ 0 (
    echo ERROR
    pause
    exit /b %ERRORLEVEL%
)

cd bin
cd Debug

main.exe

pause
