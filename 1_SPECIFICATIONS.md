# 1. SPECIFICATIONS: Escalado B2B, Multi-tenant, y Modernización UI

## 1.1 Objetivo del Proyecto
El objetivo principal es evolucionar la aplicación actual (Oficina Eficiencia) a un producto de grado empresarial (B2B) comercializable. Esto implica refactorizar la arquitectura monolítica actual hacia un sistema robusto, concurrente, con soporte de múltiples inquilinos locales (Multi-tenant offline), protección de propiedad intelectual mediante DRM offline, y una interfaz de usuario moderna y fluida que elimine las interrupciones operativas (sin reinicios para generación de reportes).

**🚨 DIRECTIVA ESTRICTA (ANTI-VIBE HACKING) 🚨**
> Las IAs (agentes o LLMs, incluyendo Antigravity) que lean, interpreten o implementen este documento **NO DEBEN** desviarse, "alucinar" atajos, omitir pasos de seguridad, ni alterar el diseño arquitectónico establecido. Toda modificación que comprometa el flujo concurrente o la encriptación de seguridad debe ser rechazada. No se permiten "soluciones rápidas" que degraden la robustez del sistema en favor de la simplicidad temporal.

## 1.2 Arquitectura y Componentes Clave

### 1.2.1 Soporte Multi-Tenant (Inquilinos Locales)
Para que el software se pueda vender a empresas con diferentes sucursales o departamentos, se implementará un esquema Multi-tenant local.
- **Aislamiento de Datos:** Todos los datos (SQLite, Snapshots, Faces, Configuraciones, Zonas) deben estar particionados lógicamente por "Tenant" dentro de `%APPDATA%/OficinaEficiencia/Tenants/<Tenant_ID>/`.
- **Selección de Entorno:** Al iniciar la aplicación, si existe más de un perfil creado, el usuario administrador elegirá a qué Tenant/Sucursal va a ingresar.

### 1.2.2 Sistema DRM Offline y Licenciamiento
Para evitar la piratería y distribución no autorizada, se requiere un mecanismo robusto de Digital Rights Management (DRM) que opere 100% offline.
- **Hardware Binding:** Se generará un Hash de Hardware único combinando números de serie de la placa base (Motherboard), procesador (CPU) y disco principal (usando librerías estáticas de recolección de WMI en Windows).
- **Activación por Claves (Key System):** El cliente ingresará una clave de licencia cifrada asimétricamente (RSA o AES256 GCM) generada por el proveedor. El software verificará localmente si el hash contenido en la clave coincide con el hardware actual y validará la fecha de expiración.
- **Ofuscación:** Todo el código Python, y en especial el módulo DRM, será ofuscado utilizando `PyArmor` (modo restrictivo) antes de empaquetarse con PyInstaller (`compilar_exe.bat`), impidiendo la descompilación y modificación directa del binario.

### 1.2.3 Soporte Multicámara y Concurrencia
- **Arquitectura de Hilos (Threading):** El bucle principal (`src/main.py`) que actualmente bloquea la interfaz se desvinculará. Cada cámara procesada por YOLO/OpenCV correrá en un hilo independiente (o subproceso `multiprocessing` para eludir el GIL de Python, dependiendo de la carga de inferencia).
- **Gestión Unificada:** El sistema debe soportar N cámaras concurrentes (RTSP/USB) procesando detección, reconocimiento y análisis de zonas de forma simultánea.

### 1.2.4 Modernización de UI/UX (Fluid Experience)
Se abandona el enfoque básico de `Tkinter` "rústico" (que se reinicia al cambiar de contexto o exportar reportes).
- **Framework Nuevo:** Transición a `CustomTkinter` (o alternativamente `PyQt6` / `PySide6`) para ofrecer una interfaz oscura/clara moderna, con bordes redondeados, menús laterales expansibles y navegación por pestañas integradas.
- **Grid de Monitoreo:** La ventana principal tendrá un "Dashboard" donde se verán las transmisiones en vivo de todas las cámaras en una cuadrícula (Grid view). El usuario podrá hacer doble clic en una cámara para expandirla y ver solo esa transmisión (Single view), y viceversa.
- **Generación de Reportes en Caliente:** El módulo de reportes (Excel) se ejecutará en un hilo en segundo plano asíncrono. Los usuarios podrán solicitar reportes históricos o en tiempo real sin detener el flujo de las cámaras ni reiniciar el ejecutable.

## 1.3 Seguridad y Prevención de Hackeos ("Anti-Vibe Hacking")
- **Encriptación en Reposo:** La base de datos local SQLite y los archivos de configuración JSON de zonas deben ser encriptados (ej. usando SQLCipher o PyCryptodome AES para los blobs).
- **Validación de Inputs:** Todas las entradas de usuario, subida de imágenes (caras de empleados) y rutas de cámaras estarán sujetas a validación estricta para prevenir inyecciones (Path Traversal o Command Injection).
- **Integridad de Modelos AI:** Los pesos (`yolov8n.pt`, modelos de reconocimiento) no pueden ser modificados por usuarios. La aplicación verificará sus hashes SHA-256 en tiempo de ejecución.
- **Ausencia de Backdoors:** La IA encargada de la codificación tiene estrictamente prohibido incluir endpoints ocultos, contraseñas codificadas (hardcoded), "master keys" en texto plano, o telemetría secreta. El log de fallos (`crash_log.txt`) debe sanitizar datos personales e IP antes de escribirse localmente.

## 1.4 Estándares de Documentación y Código
- Todos los comentarios y strings de documentación (docstrings) generados por el agente deben estar escritos en **español**.
- Cualquier cambio de estado que afecte al Tenant activo o permisos de Administrador debe registrarse en una tabla `audit_log` en la base de datos cifrada.
- Se mantendrá el parche actual: `os.environ['KMP_DUPLICATE_LIB_OK'] = 'TRUE'` y la importación de `torch` previa a `cv2` para evitar crasheos de OpenMP en Windows.
