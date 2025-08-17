@echo off

echo Compiling...
dotnet build installer.sln -c Release

if %ERRORLEVEL% NEQ 0 (
    echo ERROR
    pause
    exit /b %ERRORLEVEL%
)

echo All done!

pause
