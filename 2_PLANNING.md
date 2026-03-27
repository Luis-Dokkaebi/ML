# 2. PLANNING: Fases de Escalamiento B2B y Arquitectura General

## 2.1 Visión General del Plan de Acción
Para transformar la base de código actual (Oficina Eficiencia) en un producto distribuible y escalable, se implementará una transición paulatina y controlada. Esto minimizará los riesgos (crash de la UI, regresiones en inferencia o base de datos) al introducir nuevas tecnologías (CustomTkinter/PyQt, Hilos, DRM) en un sistema existente que antes era sincrónico (monolítico).

**🚨 DIRECTIVA DE EJECUCIÓN 🚨**
> El Agente de IA encargado de ejecutar este plan debe adherirse estrictamente a estas fases de desarrollo, sin agrupar pasos arbitrariamente ni mezclar código de seguridad (DRM) con actualizaciones de UI, ya que un fallo simultáneo dificultará la depuración. Los comentarios en código serán puramente en **español** para todos los aportes nuevos o refactorizaciones. Toda alucinación que proponga saltarse este orden jerárquico será catalogada como "Vibe Hacking" y detenida.

## 2.2 Fases de Desarrollo (Metodología Ágil)

### Fase 1: Desacoplamiento de Núcleo y Arquitectura de Hilos
**Objetivo:** Eliminar el cuello de botella sincrónico en `src/main.py` y `src/main2.py` que bloqueaba la interfaz de usuario al generar reportes o cargar el feed de cámara.
- **Paso 1.1:** Separar lógica de adquisición de frames (OpenCV) y la inferencia YOLOv8/Reconocimiento Facial en Hilos de Trabajo (`threading.Thread` o `multiprocessing.Process` en caso de inferencia intensiva).
- **Paso 1.2:** Crear un Gestor de Cámaras (`CameraManager`) capaz de instanciar y mantener activas múltiples fuentes de video (cámaras web USB o streams RTSP) concurrentemente.
- **Paso 1.3:** Implementar colas de mensajes en memoria (`queue.Queue`) para pasar frames anotados de vuelta al hilo principal de la interfaz sin interbloqueos (deadlocks).
- **Paso 1.4:** Reestructurar los métodos de generación de reportes (Excel) a funciones asíncronas para que el usuario pueda exportar datos mientras las cámaras siguen en vivo (Operación Continua).

### Fase 2: Modernización de Interfaz Gráfica (Fluid UI)
**Objetivo:** Reemplazar el "Tkinter rústico" y los reinicios del ejecutable con una experiencia "Dashboard" unificada y continua (Single-Window Application).
- **Paso 2.1:** Migrar a `CustomTkinter` para aplicar temas oscuros/claros, bordes redondeados y tipografías modernas.
- **Paso 2.2:** Crear un menú lateral (Sidebar) persistente para navegar entre módulos (Monitoreo, Empleados, Zonas, Reportes, Settings) sin cerrar la ventana.
- **Paso 2.3:** Diseñar la vista principal "Grid View" que mostrará una cuadrícula dinámica según el número de cámaras activas (1x1, 2x2, 3x3, etc.).
- **Paso 2.4:** Programar la interacción interactiva: Al hacer doble clic sobre el feed de una cámara, esta pasará a "Single View" (vista expandida a pantalla completa del panel central), y al volver a hacer doble clic regresará al Grid.

### Fase 3: Aislamiento Multi-Tenant (Local B2B)
**Objetivo:** Permitir que la misma instalación en Windows pueda gestionar datos separados (empleados, zonas, eventos, bd) para múltiples entidades (Sucursales/Empresas).
- **Paso 3.1:** Extender `config/config.py` y `path_utils.py` para abstraer la raíz del directorio base (ej. de `%APPDATA%/OficinaEficiencia` a `%APPDATA%/OficinaEficiencia/Tenants/[Tenant_ID]/`).
- **Paso 3.2:** Diseñar la Pantalla de Login/Selección de Tenant al inicio (boot) de la aplicación.
- **Paso 3.3:** Modificar `DatabaseManager` (`src/storage/database_manager.py`) para que reciba la ruta dinámica de la base de datos `local_tracking.db` según el Tenant activo en sesión.
- **Paso 3.4:** Añadir en la interfaz la funcionalidad de Alta, Baja y Modificación de Tenants (CRUD de Sucursales locales) solo para administradores.

### Fase 4: Seguridad, Cifrado y DRM Offline
**Objetivo:** Blindar el software para comercialización, proteger la IP del código y datos del cliente, asegurando un entorno "Anti-Hackeo".
- **Paso 4.1:** Implementar el módulo DRM `HardwareFingerprint` que extraiga identificadores de CPU, Placa Base y Disco (usando `wmi` en Windows) y genere un Hash Único.
- **Paso 4.2:** Desarrollar el sistema de validación offline: La aplicación solicitará un archivo/texto `.lic` o "Product Key". Descifrará localmente la clave (usando una llave pública integrada) para contrastar el Hash del equipo y verificar que la fecha límite no ha expirado.
- **Paso 4.3:** Incorporar cifrado de base de datos (`SQLCipher` para SQLite), reemplazando el SQLite estándar para que un usuario malicioso no pueda alterar la base de datos del sistema para saltarse restricciones de Tenant o inyectar usuarios no autorizados.
- **Paso 4.4:** Configurar `PyArmor` en el script de construcción (`compilar_exe.bat`). Ofuscar todo el directorio `src/` antes de que PyInstaller genere el ejecutable `.exe`, impidiendo la descompilación con herramientas como `uncompyle6`.

## 2.3 Arquitectura Conceptual (Diagrama Descriptivo)
El sistema pasará de un flujo lineal (Init -> Main Loop OpenCV/UI -> Close) a un sistema Basado en Eventos (Event-Driven):

[Tenant Selector & DRM Validator]
        |
        V
[Main Application Window (CustomTkinter - Main Thread)]
  |-- [Sidebar Navigation] --> Controla Vistas (Reportes, Config, Monitoreo)
  |-- [Dashboard Central]  --> Renderiza Frames Recibidos
        ^
        | (Queue de Frames / Eventos)
        |
[CameraManager (Background Daemon)]
  |-- Hilo Camara 1 (OpenCV Read -> YOLO Infer -> ZoneLogic -> Storage)
  |-- Hilo Camara 2 (OpenCV Read -> YOLO Infer -> ZoneLogic -> Storage)
  |-- Hilo Reportes (Ejecución en Background, sin pausar cámaras)

## 2.4 Hitos del Proyecto
1. **Hito 1 (Core Concurrente):** El sistema puede leer 4 streams RTSP simultáneos sin crash y actualizar una UI en tiempo real.
2. **Hito 2 (Continuidad Operativa):** El usuario genera un reporte Excel mensual en la misma ventana, las cámaras siguen grabando y reportando sin detenerse ni un solo frame.
3. **Hito 3 (Escalabilidad de Negocio):** Se crean 2 sucursales "Tenant A" y "Tenant B" en la misma PC; sus bases de datos SQLite y perfiles de Rostros (Faces) están 100% aislados en carpetas separadas.
4. **Hito 4 (Productización Final):** El sistema no corre sin una Clave de Licencia válida de hardware; el binario es irreconocible por ofuscación y los datos están encriptados en `%APPDATA%`.
