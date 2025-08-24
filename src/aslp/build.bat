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

@REM close sven exe + force move file?

pause