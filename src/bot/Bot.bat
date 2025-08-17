@echo off

dotnet build Bot.sln

if %ERRORLEVEL% NEQ 0 (
    echo ERROR
    pause
    exit /b %ERRORLEVEL%
)

cd ..
cd ..
cd build
cd ChatBridge

ChatBridge.exe -token "test_token"

@pause
