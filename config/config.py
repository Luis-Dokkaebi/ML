# --- config/config.py ---
import os
<<<<<<< HEAD
from config.path_utils import get_resource_path, ConfigManager
=======
from config.path_utils import get_resource_path, get_appdata_path

# --- Versioning ---
VERSION = "1.0.0" # Springback default
try:
    version_path = get_resource_path('VERSION')
    if os.path.exists(version_path):
        with open(version_path, 'r') as f:
            VERSION = f.read().strip()
except Exception:
    pass

# ── Writable user-data directories (all under %APPDATA%\OficinaEficiencia) ──
APP_DATA_DIR  = get_appdata_path()
DATA_DIR      = get_appdata_path('data')
FACES_DIR     = get_appdata_path('data', 'faces')
ZONAS_DIR     = get_appdata_path('data', 'zonas')
CALIBRATION_DIR = get_appdata_path('data', 'config')

# Ensure sub-dirs exist (get_appdata_path already creates them, but be explicit)
for sub_dir in ['db', 'snapshots']:
    os.makedirs(os.path.join(DATA_DIR, sub_dir), exist_ok=True)

# ── Read-only resource paths (bundled with the exe) ──
MODEL_PATH = get_resource_path('yolov8n.pt')
>>>>>>> 8d3f727186210ccd9781bda20208ecb76b335c42

# --- Versioning ---
VERSION = "2.0.0" 
try:
    version_path = get_resource_path('VERSION')
    if os.path.exists(version_path):
        with open(version_path, 'r') as f:
            VERSION = f.read().strip()
except Exception:
    pass

MODE = 'local'

# Video
LOCAL_CAMERA_INDEX = 0
REMOTE_CAMERA_URL = "rtsp://usuario:contraseña@IP:PUERTO/cam/path"

<<<<<<< HEAD
# Getter based configuration to support B2B Hot-Swapping Multi-Tenant
# No evaluarlas al instante de importacion! El Tenant debe ser seleccionado primero por el Bootloader.
def get_db_path():
    return os.path.join(ConfigManager.get_tenant_path('db'), 'local_tracking.db')

def get_faces_dir():
    return ConfigManager.get_tenant_path('faces')

def get_zonas_file():
    return os.path.join(ConfigManager.get_tenant_path('zonas'), 'zonas_config.json')

def get_snapshots_dir():
    return ConfigManager.get_tenant_path('snapshots')

def get_export_dir():
    return ConfigManager.get_tenant_path('export')

# Read-only resource paths
MODEL_PATH = get_resource_path('yolov8n.pt')
=======
# Base de datos
LOCAL_DB_PATH = os.path.join(DATA_DIR, 'db', 'local_tracking.db')
REMOTE_DB_URL = 'mysql://usuario:contraseña@servidor_ip/dbname'

# Zonas
ZONAS_FILE = os.path.join(ZONAS_DIR, 'zonas.json')

# Snapshots
SNAPSHOTS_DIR = os.path.join(DATA_DIR, 'snapshots')
>>>>>>> 8d3f727186210ccd9781bda20208ecb76b335c42

# Otros parámetros generales
FRAME_SKIP = 1  
CONFIDENCE_THRESHOLD = 0.4
