@echo off
echo =========================================================
echo  OFICINA EFICIENCIA B2B - BUILD PIPELINE SECOPS
echo  PyArmor 8 (Ofuscacion) + PyInstaller (Empaquetado)
echo =========================================================
echo.

REM ---- PASO 0: Configuracion de entorno ----
set VENV=.\venv\Scripts
set PYARMOR=%VENV%\pyarmor
set PYINSTALLER=%VENV%\pyinstaller
set PIP=%VENV%\python.exe -m pip
set OBFUSCATED_DIR=dist\obfuscated

REM Prevenir crash OpenMP (Riesgo 1 de 2_PLANNING.md)
set KMP_DUPLICATE_LIB_OK=TRUE

echo [PASO 1/5] Limpiando builds anteriores...
if exist build rmdir /s /q build
if exist "%OBFUSCATED_DIR%" rmdir /s /q "%OBFUSCATED_DIR%"
if exist dist\OficinaEficiencia_VMS rmdir /s /q dist\OficinaEficiencia_VMS
echo           [OK] Directorios limpiados.
echo.

echo [PASO 2/5] Verificando dependencias criticas...
%PIP% install lapx --quiet 2>nul
echo           [OK] Dependencias verificadas.
echo.

echo [PASO 3/5] Ofuscando codigo fuente con PyArmor 8...
echo           Modo: obf-module=1 obf-code=1 (bytecode propietario)
echo           Alcance: src/ y config/ recursivo
%PYARMOR% gen -O "%OBFUSCATED_DIR%" -r --obf-module 1 --obf-code 1 src config
if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR FATAL] PyArmor fallo al ofuscar. Abortando build.
    echo Verifique la licencia de PyArmor y la estructura de src/
    pause
    exit /b 1
)
echo           [OK] Codigo ofuscado generado en %OBFUSCATED_DIR%
echo.

echo [PASO 4/5] Compilando binario ofuscado con PyInstaller...
%PYINSTALLER% --noconfirm gui_app.spec
if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR FATAL] PyInstaller fallo al empaquetar. Abortando build.
    pause
    exit /b 1
)
echo           [OK] Ejecutable generado en dist\OficinaEficiencia_VMS\
echo.

echo [PASO 5/6] Validacion post-build...
if exist "dist\OficinaEficiencia_VMS\OficinaEficiencia_VMS.exe" (
    echo           [OK] BUILD B2B EXITOSO
) else (
    echo [ERROR] No se encontro el ejecutable final. Revise los logs.
    pause
    exit /b 1
)
echo.

echo [PASO 6/6] Empaquetando Instalador con Inno Setup...
if exist "C:\Program Files (x86)\Inno Setup 6\iscc.exe" (
    "C:\Program Files (x86)\Inno Setup 6\iscc.exe" setup_oficina.iss
    echo           [OK] Instalador generado en installer_output\
) else (
    echo [WARNING] Inno Setup no encontrado. Instalador omitido.
)
echo.
pause
