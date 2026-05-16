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

REM Conda loops removed due to corrupted environment

echo Leyendo version desde archivo VERSION...
set /p APP_VERSION=<VERSION

.\venv\Scripts\pyinstaller --noconfirm --onedir ^
    --add-data "data;data" ^
    --add-data "models;models" ^
    --add-data "src;src" ^
    --add-data "config;config" ^
    --add-data "yolov8n.pt;." ^
    --add-data "VERSION;." ^
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
    --name OficinaEficiencia_VMS ^
    src/main_ui.py

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
