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

<<<<<<< HEAD
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
=======
echo Obteniendo ruta de librerias binarias de Conda/Python...
FOR /F "tokens=*" %%g IN ('python -c "import sys, os; print(os.path.join(sys.prefix, 'Library', 'bin'))"') do (SET CONDA_BIN=%%g)
FOR /F "tokens=*" %%g IN ('python -c "import face_recognition_models, os; print(os.path.dirname(face_recognition_models.__file__))"') do (SET FACE_MODELS=%%g)
FOR /F "tokens=*" %%g IN ('python -c "import torch, os; print(os.path.join(os.path.dirname(torch.__file__), 'lib'))"') do (SET TORCH_LIB=%%g)
FOR /F "tokens=*" %%g IN ('python -c "import cv2, os; print(os.path.join(os.path.dirname(cv2.__file__), 'data'))"') do (SET CV2_DATA=%%g)

echo Leyendo version desde archivo VERSION...
set /p APP_VERSION=<VERSION

pyinstaller --noconfirm --onedir ^
    --add-data "data;data" ^
    --add-data "models;models" ^
    --add-data "src;src" ^
    --add-data "config;config" ^
    --add-data "yolov8n.pt;." ^
    --add-data "VERSION;." ^
    --add-data "%FACE_MODELS%;face_recognition_models" ^
    --add-data "%CV2_DATA%;cv2/data" ^
    --add-binary "%CONDA_BIN%\mkl_*.dll;." ^
    --add-binary "%TORCH_LIB%\libiomp5md.dll;." ^
    --hidden-import ultralytics ^
    --hidden-import supervision ^
    --hidden-import shapely ^
    --hidden-import tkcalendar ^
    --hidden-import babel.numbers ^
    --hidden-import reportlab ^
    --hidden-import config.config ^
    --hidden-import config.path_utils ^
    --collect-all ultralytics ^
    --collect-all supervision ^
    --collect-all shapely ^
    --collect-all tkcalendar ^
    --copy-metadata ultralytics ^
    src/gui_app.py

echo.
echo =========================================================
echo Compilacion PyInstaller Finalizada.
echo Generando Instalador para version %APP_VERSION%...
echo =========================================================

"c:\Program Files (x86)\Inno Setup 6\ISCC.exe" /DMyAppVersion=%APP_VERSION% setup_oficina.iss

echo.
echo =========================================================
echo Proceso Finalizado.
echo El instalador se encuentra en: installer_output\setup_oficina_eficiencia_v%APP_VERSION%.exe
echo =========================================================
>>>>>>> 8d3f727186210ccd9781bda20208ecb76b335c42
