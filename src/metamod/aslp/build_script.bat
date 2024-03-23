@echo off

echo Iniciando el script de compilación...

set "SC=svencoop.exe"
set "DLLPath=C:\Program Files (x86)\Steam\steamapps\common\Sven Co-op\svencoop_addon\src\metamod\Release\aslp.dll"
set "DestinationPath=C:\Program Files (x86)\Steam\steamapps\common\Sven Co-op\svencoop\addons\metamod\dlls"

echo Verificando si el proceso %SC% está en ejecución...
tasklist | find /i "%SC%" > nul
if %errorlevel% equ 0 (
    echo El proceso %SC% está en ejecución.
    echo Cerrando el proceso %SC%...
    taskkill /f /im %SC%

    echo Esperando 5 segundos antes de continuar...
    ping 127.0.0.1 -n 6 > nul  // Espera 5 segundos (1 segundo adicional para la seguridad)

    echo Verificando nuevamente si el proceso %SC% se ha cerrado...
    tasklist | find /i "%SC%" > nul
    if %errorlevel% equ 0 (
        echo El proceso %SC% no se cerró correctamente.
    ) else (
        echo Proceso %SC% cerrado con éxito.
    )
) else (
    echo El proceso %SC% no está en ejecución.
)

echo Copiando el archivo %DLLPath% a %DestinationPath%...
copy "%DLLPath%" "%DestinationPath%"
if %errorlevel% equ 0 (
    echo Copia completa.
) else (
    echo ¡Error al copiar el archivo!
)

echo Finalizando el script de compilación.
pause