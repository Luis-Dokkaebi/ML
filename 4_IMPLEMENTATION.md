# 4. IMPLEMENTATION: Guía Técnica de Código y Seguridad Anti-Hacking (B2B)

Este documento contiene los detalles técnicos, fragmentos de código, librerías y estándares que se deben utilizar para implementar el escalamiento B2B de "Oficina Eficiencia". Todo código escrito debe cumplir con estas especificaciones para ser aceptado y compilado.

**🚨 DIRECTIVA ESTRICTA DE SEGURIDAD (ANTI-VIBE HACKING) 🚨**
> El Agente IA desarrollador (ej. Antigravity) **NO TIENE PERMITIDO** instalar librerías no listadas aquí, modificar la arquitectura de hilos sugerida, o insertar claves (API Keys/Passwords) en texto plano. Todo acceso a la base de datos debe usar sentencias parametrizadas (evitar concatenación de strings para prevenir Inyección SQL). Las validaciones DRM deben ocurrir en memoria y no escribirse en archivos temporales descifrados.

---

## 4.1 Módulo 1: Concurrencia (Hilos y Multiprocesamiento)

El mayor desafío técnico es procesar inferencias de YOLOv8 (reconocimiento de personas/zonas) en múltiples cámaras sin bloquear el hilo principal (Main Thread) donde corre `CustomTkinter`.

**Patrón de Diseño Recomendado: Productor-Consumidor (Queues)**
- **Productor:** Un hilo independiente por cada cámara (`CameraWorker`). Este hilo capturará el frame con `cv2.VideoCapture()`, ejecutará `YOLOv8.predict()`, dibujará las Bounding Boxes/Polígonos de Zona, y finalmente colocará el frame procesado (como array de NumPy) en una `queue.Queue()`.
- **Consumidor:** El hilo principal (`CustomTkinter` a través de `.after(10, update_frames)`) vaciará estas colas, convertirá el frame de BGR a RGB, lo redimensionará (`cv2.resize()`), lo convertirá a un objeto `PIL.ImageTk.PhotoImage` y lo asignará al label/canvas correspondiente en el Grid.

```python
# Ejemplo de Productor
import cv2
import queue
import threading
from ultralytics import YOLO

class CameraWorker(threading.Thread):
    def __init__(self, camera_id, frame_queue, model):
        super().__init__()
        self.camera_id = camera_id
        self.queue = frame_queue
        self.model = model
        self.running = True

    def run(self):
        cap = cv2.VideoCapture(self.camera_id)
        while self.running:
            ret, frame = cap.read()
            if ret:
                results = self.model(frame) # Inferencia
                annotated_frame = results[0].plot() # BBoxes
                if not self.queue.full():
                    self.queue.put((self.camera_id, annotated_frame))
        cap.release()
```

## 4.2 Módulo 2: Interfaz "Fluid" (CustomTkinter Multi-Tenant)

- La ventana principal será una instancia de `customtkinter.CTk()`.
- Se usará `customtkinter.CTkFrame()` para dividir el Layout en: **Sidebar (Izquierda)** y **Dashboard (Centro)**.
- El Dashboard central usará `.grid()` para posicionar dinámicamente los frames de las cámaras.

**Manejo de Operaciones Asíncronas (Reportes sin crashear):**
Para generar un reporte de Excel pesado sin que la UI se congele o parpadee "No Responde":
```python
import threading

def generar_reporte_async(self):
    # Función llamada por un Botón de UI
    def tarea():
        # Lógica pesada de base de datos a pandas y excel
        DatabaseManager.exportar_a_excel('ruta.xlsx')
        self.mostrar_mensaje_exito("Reporte Generado") # Debe ser Thread-Safe

    threading.Thread(target=tarea, daemon=True).start()
```

**Múltiples Inquilinos (Tenants):**
El ID del Tenant seleccionado en la pantalla inicial de Login se guardará en memoria global o en una clase "Singleton" (ej. `SessionManager.active_tenant = "SucursalA"`).
Todo acceso a rutas de datos usará `config.get_appdata_path('Tenants', SessionManager.active_tenant, 'db')`.

## 4.3 Módulo 3: Protección B2B (DRM Offline)

El DRM (Digital Rights Management) protegerá el software vinculándolo físicamente al hardware de la PC del cliente.

**Librería Principal:** `wmi` (Windows Management Instrumentation). Solo compatible con Windows.

**Algoritmo de Hash (Hardware Fingerprint):**
```python
import wmi
import hashlib

def generar_hardware_id():
    c = wmi.WMI()
    cpu_serial = c.Win32_Processor()[0].ProcessorId.strip()
    board_serial = c.Win32_BaseBoard()[0].SerialNumber.strip()
    disk_serial = c.Win32_DiskDrive()[0].SerialNumber.strip() # Preferible disco C:

    raw_string = f"{cpu_serial}-{board_serial}-{disk_serial}"
    hw_hash = hashlib.sha256(raw_string.encode('utf-8')).hexdigest()
    return hw_hash # Este es el MachineID
```

**Validación de Clave (License Key):**
- El Proveedor (tú) generará una clave cifrando el `MachineID` junto con una `Fecha_Expiracion` (ej. "2024-12-31") usando una Llave Privada RSA o AES-GCM.
- El Cliente ingresa el string Base64 resultante.
- El Software, al arrancar, descifra el string usando su Llave Pública. Si el `MachineID` descifrado coincide con el Hash local (calculado en ese instante) y la fecha de expiración es futura, el software carga; en caso contrario, muestra "Licencia Inválida" y llama a `sys.exit()`.

## 4.4 Módulo 4: Ofuscación (PyArmor) y Compilación (PyInstaller)

Para evitar que un ingeniero inverso extraiga la lógica DRM en Python o la Llave Pública:

1. Modificar `compilar_exe.bat` para que, antes de llamar a `pyinstaller gui_app.spec`, se ofusquen los módulos clave.
2. Comando sugerido: `pyarmor gen -O ofuscado --restrict 1 src/`
3. Esto generará una carpeta `ofuscado/src/` con scripts que importan un `.pyd` compilado nativo (ilegible).
4. El archivo `gui_app.spec` apuntará a la carpeta `ofuscado` en lugar del código original fuente durante la fase de análisis (`Analysis(['ofuscado/src/gui_app.py', ...])`).

**Resolución de Dependencias:** Mantener siempre `os.environ['KMP_DUPLICATE_LIB_OK'] = 'TRUE'` al inicio de la ejecución (`gui_app.py` / `main.py`) y la carga prioritaria de dependencias binarias complejas (como `torch` antes que `cv2`).
