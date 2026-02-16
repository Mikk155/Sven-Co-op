@echo off

setlocal

taskkill /F /IM "svencoop.exe"

cmake --build ../../build/aslp --config Release --clean-first

if %ERRORLEVEL% NEQ 0 (
    echo ERROR
    pause
    exit /b %ERRORLEVEL%
)

"C:\Users\Usuario\Desktop\Sven Co-op.url"

pause

taskkill /F /IM "svencoop.exe"
