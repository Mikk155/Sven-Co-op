@echo off

echo Compiling...

set APPNAME=MKAssetInstaller

dotnet build installer.sln -p:AssemblyName=%APPNAME% -c Release

if %ERRORLEVEL% NEQ 0 (
    echo ERROR
    pause
    exit /b %ERRORLEVEL%
)

echo All done!

pause
