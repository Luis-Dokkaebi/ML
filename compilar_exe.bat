@echo off
echo =========================================================
echo Empaquetando Aplicacion de Sistema de Monitoreo
echo =========================================================

echo Instalando PyInstaller si no existe...
pip install pyinstaller

echo Habilitando bypass para conflictos de OpenMP entre librerias NumPy y PyTorch...
set KMP_DUPLICATE_LIB_OK=TRUE

echo Obteniendo ruta de librerias binarias de Conda/Python...
FOR /F "tokens=*" %%g IN ('python -c "import sys, os; print(os.path.join(sys.prefix, 'Library', 'bin'))"') do (SET CONDA_BIN=%%g)
FOR /F "tokens=*" %%g IN ('python -c "import face_recognition_models, os; print(os.path.dirname(face_recognition_models.__file__))"') do (SET FACE_MODELS=%%g)
FOR /F "tokens=*" %%g IN ('python -c "import torch, os; print(os.path.join(os.path.dirname(torch.__file__), 'lib'))"') do (SET TORCH_LIB=%%g)

echo Compilando ejecutable con soporte para MKL...
:: Notas: 
:: --noconfirm: Sobrescribe la carpeta de salida existente
:: --onedir: Crea un directorio (más rápido de cargar que onefile)
:: --windowed: Oculta la consola (ideal para GUI). Lo dejamos sin esto para que YOLO reporte progreso, o activarlo si el cliente lo prefiere.
:: --add-data: Copiamos carpetas vitales.
:: Se agregan los binarios de entorno conda si existen para evitar el error de MKL.

pyinstaller --noconfirm --onedir ^
    --add-data "data;data" ^
    --add-data "models;models" ^
    --add-data "src;src" ^
    --add-data "yolov8n.pt;." ^
    --add-data "%FACE_MODELS%;face_recognition_models" ^
    --add-data "config;config" ^
    --add-binary "%CONDA_BIN%\mkl_*.dll;." ^
    --add-binary "%TORCH_LIB%\libiomp5md.dll;." ^
    --hidden-import ultralytics ^
    --hidden-import supervision ^
    --collect-all ultralytics ^
    --collect-all supervision ^
    --copy-metadata ultralytics ^
    --hidden-import config.config ^
    --hidden-import config.config ^
    src/gui_app.py

echo.
echo =========================================================
echo Compilacion Finalizada.
echo El ejecutable se encuentra en: dist\gui_app\gui_app.exe
echo =========================================================
pause
