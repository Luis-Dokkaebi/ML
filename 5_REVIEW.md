# 5. REVIEW: Validación Final y Auditoría de Sistema B2B

El propósito de esta etapa es validar rigurosamente la entrega de las Fases 1 a 4. Un software de grado Enterprise (B2B) debe pasar todas las pruebas funcionales, de rendimiento y, crucialmente, de seguridad (DRM / Anti-Hacking) antes de generar el instalador (.exe) final y enviarlo a clientes.

**🚨 DIRECTIVA ESTRICTA DE AUDITORÍA (ANTI-VIBE HACKING) 🚨**
> *La Inteligencia Artificial que revise este código tiene estrictamente prohibido simular, inferir o "saltarse" estas pruebas.* Toda validación (Mock/Test) debe ejecutarse contra los binarios y el código fuente real. Ningún "Pull Request" o "Commit" que omita el paso por el "Checklist de Seguridad (5.3)" debe ser aprobado. Las pruebas deben ejecutarse en un entorno Windows nativo (o Sandbox equivalente) para verificar la correcta extracción de los parámetros WMI (Hardware ID) y el soporte multi-hilo de UI.

---

## 5.1 Criterios de Aceptación Funcional

Antes de considerar el producto "Terminado", se deben superar las siguientes pruebas de caja negra (Black-Box Testing) por el usuario o equipo de QA:

*   [ ] **Validación Multi-Cámara (Hito 1):** Iniciar la aplicación con al menos dos (2) fuentes de video (cámara USB 0 y RTSP remoto o archivo local .mp4 como emulación). Ambos streams deben renderizarse de forma simultánea (Grid) sin caídas de framerate significativas, y con Bounding Boxes generados asincrónicamente por el modelo YOLO.
*   [ ] **Validación de Operatividad Continua (Hito 2):** Mientras las cámaras se están monitoreando activamente en la pantalla principal (Dashboard), un usuario hace clic en "Generar Reporte de Asistencia" (botón Sidebar). El archivo Excel se crea exitosamente en el disco sin que las transmisiones de video se "congelen", parpadeen o requieran un reinicio del ejecutable.
*   [ ] **Validación Interfaz Fluida (Hito 2):** Se reemplazó la UI clásica de Tkinter. Los menús de navegación, los botones redondeados y la interacción del Grid a Single View (doble clic en el frame) responden sin retraso (lag).
*   [ ] **Validación Multi-Tenant (Hito 3):** Se crean 2 Entidades desde la Configuración de Administrador: "Sucursal Norte" y "Sucursal Sur". Al ingresar en "Sucursal Sur" y registrar el rostro de un Empleado (Juan), y posteriormente cerrar sesión e ingresar como "Sucursal Norte", Juan **no debe aparecer** en la base de datos ni en la carpeta local de la Sucursal Norte (Aislamiento de `%APPDATA%/OficinaEficiencia/Tenants/`).

## 5.2 Pruebas Unitarias y de Integración (TDD)

El repositorio debe contener un directorio `tests/` actualizado con los nuevos tests (ej. usando `pytest` o `unittest`):

*   [ ] **Test de Desempeño (Hilos):** `test_camera_manager_queues`. Comprueba que el productor de video no bloquee al consumidor de UI, verificando la longitud de la cola y el tiempo de respuesta.
*   [ ] **Test DRM:** `test_hardware_hash_consistency`. El hash generado a partir de CPU+Motherboard+Disk (`wmi`) debe ser determinista e idéntico a través de múltiples llamadas en la misma máquina física o VM.
*   [ ] **Test de Aislamiento de Paths:** `test_tenant_path_resolution`. Validar que si `SessionManager.active_tenant = 'X'`, la función `get_appdata_path('db')` devuelva la subcarpeta exclusiva del Tenant X.

## 5.3 Checklist de Seguridad y Anti-Hacking (Auditoría B2B)

Esta es la sección más crítica. El software no será comercializado si falla alguno de estos puntos:

*   [ ] **Auditoría de Ejecutable Ofuscado (PyArmor):** Extraer los archivos del `.exe` generado por PyInstaller (usando herramientas como `PyInstxtractor`). Intentar descompilar los `.pyc` clave (ej. `src/security/drm.py` o `src/storage/database_manager.py`) con `uncompyle6` o decompiladores online. La prueba **pasa** si los archivos resultan ilegibles (ofuscados/encriptados por PyArmor) y la lógica de validación de licencias y acceso a la BD no es visible.
*   [ ] **Inviolabilidad DRM (Licencia Falsa):** Intentar ingresar un hash modificado manualmente o una fecha de expiración alterada en el string de la licencia. El sistema debe detectar la firma criptográfica inválida, rechazar la licencia y cerrarse (Crash intencional o `sys.exit()`).
*   [ ] **Verificación de Encriptación Local:** Localizar la base de datos `local_tracking.db` en `%APPDATA%`. Intentar abrirla con "DB Browser for SQLite". La prueba **pasa** si la base de datos exige una clave (SQLCipher) para visualizar las tablas. No se debe poder modificar los eventos o empleados "inyectando" SQL manualmente desde fuera del ejecutable ofuscado.
*   [ ] **Ausencia de Dependencias Peligrosas:** Revisar exhaustivamente `requirements.txt` y los imports. Ninguna librería de telemetría remota no solicitada (ej. subida de logs ocultos a servidores de terceros) debe estar presente. El software se ejecuta offline.

## 5.4 Aprobación Final

Una vez que todas las validaciones estén marcadas como exitosas, se puede proceder a:
1. Generar la "Release Candidate" 1.0.0 (B2B Multi-tenant).
2. Construir el empaquetado final con Inno Setup (`setup_oficina.iss`).
3. Distribuir a los clientes empresariales, proporcionando su Clave de Licencia Única (`Hardware License Key`) generada en base a su Machine ID.
