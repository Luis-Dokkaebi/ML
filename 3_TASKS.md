# 3. TASKS: Tablero Kanban para Desarrollo de Sistema Multi-Cámara y DRM (B2B)

Este documento sirve como el backlog centralizado y la asignación de tareas granulares para los agentes (o ingenieros) responsables de implementar la modernización de "Oficina Eficiencia" hacia una solución Enterprise de Múltiples Inquilinos locales y DRM ofuscado.

**🚨 DIRECTIVA ESTRICTA PARA AGENTES (ANTI-VIBE HACKING) 🚨**
> *Se requiere la ejecución secuencial de estas tareas.* **NO SE PERMITE** agrupar tareas que involucren hilos (Threadings) con tareas de Interfaz Gráfica (CustomTkinter) o Cifrado (PyArmor/SQLCipher) en un solo Pull Request/Commit. Las tareas deben realizarse atómicamente para garantizar que un fallo en la UI no enmascare un deadlock en OpenCV. Toda respuesta de un agente que omita este nivel de granularidad o proponga "hacerlo todo de una vez" será bloqueada automáticamente.

---

## 3.1 Backlog (Tareas Pendientes - Fase 1: Arquitectura de Hilos y Concurrencia)

*   [ ] **TASK-1.1: Refactorizar `src/main.py` y `src/main2.py`:** Extraer la lógica del bucle `while True: ret, frame = cap.read()` a una clase `CameraManager` que soporte múltiples instancias.
*   [ ] **TASK-1.2: Implementar colas de mensajes (Queues):** Diseñar un sistema basado en `queue.Queue` para pasar frames procesados (con bounding boxes y zonas dibujadas) de vuelta al Hilo Principal (UI) sin bloquearlo.
*   [ ] **TASK-1.3: Convertir Reportes a Asíncronos:** Modificar `ReportGenerator` (o equivalente) para usar `threading.Thread` u operaciones asíncronas (`asyncio` o subprocesos en Windows) al generar archivos `.xlsx`. No debe pausar el procesamiento de cámara.

## 3.2 Backlog (Tareas Pendientes - Fase 2: Modernización UI "Fluid")

*   [ ] **TASK-2.1: Reemplazar `Tkinter` Básico:** Instalar y configurar `CustomTkinter` (`pip install customtkinter`). Crear la ventana raíz principal de la aplicación (`src/gui/app_main.py`).
*   [ ] **TASK-2.2: Diseñar Navegación Lateral (Sidebar):** Implementar botones de navegación: "Dashboard" (Cámaras), "Empleados" (Registro/Modificación), "Reportes" (Historial), "Configuración" (Tenant/Zonas/Reglas).
*   [ ] **TASK-2.3: Construir Grid Multi-Cámara:** Programar la vista central donde N instancias de cámara (viniendo de `CameraManager`) rendericen sus frames redimensionados (`cv2.resize` -> `PIL.ImageTk`) en una cuadrícula (ej. 2x2 para 4 cámaras).
*   [ ] **TASK-2.4: Interacción Single View / Grid View:** Añadir un evento de doble clic (ej. `<Double-1>`) sobre cualquier feed de cámara en el Grid para expandirla al tamaño completo de la ventana central. Un segundo doble clic regresará al usuario a la vista Grid.

## 3.3 Backlog (Tareas Pendientes - Fase 3: Multi-Tenant Local)

*   [ ] **TASK-3.1: Actualizar Rutas Dinámicas:** Modificar `config/path_utils.py` y `config.py` para abstraer la carpeta base `%APPDATA%/OficinaEficiencia` a `%APPDATA%/OficinaEficiencia/Tenants/`.
*   [ ] **TASK-3.2: Pantalla de Selección de Inquilino:** Diseñar una ventana inicial de inicio de sesión o selección (antes de cargar el Dashboard) donde el Administrador elija el Tenant activo (ej. "Sucursal Norte", "Sucursal Sur").
*   [ ] **TASK-3.3: Aislamiento SQLite y Archivos:** Asegurar que `DatabaseManager` reciba el `Tenant_ID` activo y apunte a `Tenants/[Tenant_ID]/db/local_tracking.db`. Los rostros de empleados deben ir a `Tenants/[Tenant_ID]/data/faces/`.

## 3.4 Backlog (Tareas Pendientes - Fase 4: DRM, Ofuscación y Cifrado)

*   [ ] **TASK-4.1: Módulo Hardware Fingerprint:** Usando la librería `wmi` en Windows, crear una función en `src/security/drm.py` que obtenga los seriales del procesador (`Win32_Processor`), placa base (`Win32_BaseBoard`) y disco primario (`Win32_DiskDrive`) y genere un hash SHA-256 inmutable.
*   [ ] **TASK-4.2: Sistema de Activación (Licencias):** Diseñar una pequeña interfaz de "Licencia Requerida". El usuario ingresará un string cifrado. El sistema debe descifrar este string localmente usando una llave pública incrustada, validando si el Hash del Hardware extraído de la licencia coincide con el Hash local (TASK-4.1) y comprobando la fecha de caducidad.
*   [ ] **TASK-4.3: Cifrado de Base de Datos SQLite:** Reemplazar el módulo estándar de `sqlite3` por `pysqlcipher3` (o equivalente compatible en Windows/PyInstaller) para cifrar los datos de empleados, zonas y eventos (passwords, registros de tiempo) con una clave maestra inyectada en tiempo de compilación o ejecución ofuscada.
*   [ ] **TASK-4.4: Configuración de PyArmor en Compilación:** Modificar `compilar_exe.bat` y `gui_app.spec`. Antes de ejecutar PyInstaller, correr `pyarmor gen --restrict 1 --pack dist src/` sobre los módulos críticos (`src/security/drm.py`, `src/main.py`, `src/storage/database_manager.py`) para imposibilitar la ingeniería inversa de los algoritmos de verificación de licencia y del sistema de Tenants.

---

## 3.5 In Progress (En Progreso)

*   [Ninguna tarea en progreso actualmente]

## 3.6 Done (Completadas)

*   [ ] **TASK-0.1: Evaluación de Arquitectura Inicial:** Analizar `config.py`, `main.py` y `gui_app.py` existentes para planificar el escalamiento (Completado en fase de planeación SDD).
*   [ ] **TASK-0.2: Redacción de Suite SDD (Spec-Driven Development):** Generar los 5 documentos Markdown para guiar a la IA y evitar "Vibe Hacking" (Completado).
