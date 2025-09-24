@echo off

@rem build
dotnet build code-runner.sln

@rem go to directory
cd ../../build/code-runner/

@rem simulate code runner extension calling the code runner program from Logger.as
code-runner.exe "C:\Users\Usuario\Documents\GitHub\Sven-Co-op\src\scripts\Mikk155\Logger.as"

pause
