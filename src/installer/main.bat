@echo off

set APPNAME=MKAssetInstaller

dotnet build installer.sln -p:AssemblyName=%APPNAME%

if %ERRORLEVEL% NEQ 0 (
    echo ERROR
    pause
    exit /b %ERRORLEVEL%
)

cd ..
cd ..
cd build
cd installer

%APPNAME%.exe

@pause
