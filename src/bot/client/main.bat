@echo off

setlocal

if not exist bin (
    mkdir bin
    cd bin
    cmake ..
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

main.exe

pause
