@echo off

dotnet build installer.sln

if %ERRORLEVEL% NEQ 0 (
    echo ERROR
    pause
    exit /b %ERRORLEVEL%
)

cd ..
cd ..
cd build
cd installer

MKInstaller.exe

@pause
