# Documentación del Sistema de Monitoreo de Eficiencia

Este documento proporciona una explicación detallada en lenguaje natural sobre cómo funciona el sistema de monitoreo de eficiencia y asistencia basado en visión por computadora.

## Introducción

El sistema está diseñado para monitorear la actividad de personas (empleados) dentro de un entorno de oficina o trabajo. Su objetivo principal es registrar la asistencia y calcular la eficiencia basándose en el tiempo que cada persona pasa en zonas específicas (por ejemplo, escritorios, salas de reuniones, áreas de descanso). Utiliza cámaras de video para detectar personas, seguirlas a través del tiempo, reconocer sus rostros para identificarlas y registrar sus movimientos en una base de datos para su posterior análisis.

## Flujo de Trabajo Principal (`main.py`)

El núcleo del sistema es el script `src/main.py`, que orquesta todos los componentes. El flujo de trabajo es el siguiente:

1.  **Inicialización**:
    -   Se carga la configuración desde `config.py` (cámaras, rutas de archivos).
    -   Se inicializan los módulos de detección, seguimiento, reconocimiento facial, verificación de zonas y base de datos.
    -   Se carga la base de datos de rostros conocidos para el reconocimiento.

2.  **Captura de Video**:
    -   El sistema se conecta a una fuente de video, que puede ser una cámara web local o una cámara IP remota.

3.  **Bucle de Procesamiento (Frame a Frame)**:
    -   Por cada cuadro (frame) de video capturado:
        -   **Detección**: Se buscan personas en la imagen utilizando inteligencia artificial.
        -   **Seguimiento (Tracking)**: Se asigna un ID único a cada persona detectada para saber que es la misma persona a lo largo del tiempo, incluso si se mueve.
        -   **Reconocimiento Facial**: Si el sistema detecta una persona cuyo ID es "Desconocido", intenta analizar su rostro. Si el rostro coincide con uno registrado en la base de datos, se le asigna el nombre correspondiente a ese ID.
        -   **Verificación de Zonas**: Se verifica si la persona está dentro de alguna de las zonas de interés definidas (ej. "Zona de Trabajo").
        -   **Registro de Eventos**:
            -   Si una persona entra a una zona, se toma una foto (snapshot) y se guarda en el disco.
            -   Se registra en la base de datos la posición de la persona, la zona en la que está y la hora exacta.
        -   **Visualización**: Se dibuja sobre el video un recuadro alrededor de la persona, mostrando su ID, su nombre (si se conoce) y la zona en la que se encuentra.

4.  **Finalización**:
    -   Al detener el sistema, se liberan los recursos de la cámara y se cierran las ventanas.

## Componentes del Sistema

A continuación se detalla el funcionamiento de cada módulo ubicado en la carpeta `src/`.

### 1. Detección de Personas (`src/detection/person_detector.py`)
Este módulo es los "ojos" del sistema. Utiliza un modelo de Inteligencia Artificial llamado **YOLOv8** (You Only Look Once, versión 8).
-   **Funcionamiento**: Analiza la imagen completa y predice dónde hay objetos.
-   **Filtrado**: El sistema está configurado para filtrar solo los objetos de tipo "persona" y descartar otros (como sillas o mesas). También filtra detecciones con baja confianza para evitar falsos positivos.

### 2. Seguimiento de Personas (`src/tracking/person_tracker.py`)
La detección por sí sola no sabe si la persona en el cuadro 1 es la misma que en el cuadro 2. El módulo de seguimiento resuelve esto.
-   **Tecnología**: Utiliza un algoritmo llamado **ByteTrack**.
-   **Funcionamiento**: Predice dónde estará la persona en el siguiente cuadro y asocia la nueva detección con la anterior basándose en la superposición de sus posiciones. Esto permite mantener un "ID de rastreo" (track_id) constante mientras la persona se mueve por la cámara.

### 3. Reconocimiento Facial (`src/recognition/face_recognizer.py`)
Este módulo da nombre a los IDs.
-   **Carga de Rostros**: Al inicio, lee las imágenes guardadas en la carpeta `data/faces`. Aprende las características únicas (codificaciones) de cada rostro.
-   **Reconocimiento en Vivo**: Cuando se detecta una persona:
    1.  Recorta la parte de la imagen correspondiente a la cara.
    2.  Genera la codificación de esa cara.
    3.  Compara matemáticamente esta codificación con las de la base de datos de rostros conocidos.
    4.  Si la diferencia es menor a un umbral de tolerancia (0.65), se considera una coincidencia y se devuelve el nombre de la persona.

### 4. Verificación de Zonas (`src/zones/zone_checker.py`)
Determina si una persona está en un lugar relevante.
-   **Definición**: Las zonas se definen como polígonos (puntos conectados) en el archivo `data/zonas/zonas.json`.
-   **Lógica**: El sistema calcula el punto central de la persona detectada (centro de sus pies o cuerpo). Luego, utiliza geometría computacional (biblioteca `shapely`) para verificar si ese punto está "dentro" de alguno de los polígonos definidos.

### 5. Base de Datos (`src/storage/database_manager.py`)
Almacena toda la información persistente utilizando **SQLite**.
-   **Tabla `tracking`**: Guarda el historial de movimiento. Cada fila contiene: ID, fecha/hora, coordenadas (x, y), nombre de la zona y si está dentro o fuera.
-   **Tabla `snapshots`**: Guarda el registro de fotos tomadas cuando alguien entra a una zona. Contiene: ID, fecha/hora, zona y la ruta del archivo de imagen.

### 6. Generación de Reportes (`src/analysis/report_generator.py`)
Transforma los datos crudos en información útil.
-   **Procesamiento**: Lee la base de datos y utiliza `pandas` para agrupar los datos.
-   **Cálculos**: Calcula la duración total que cada persona (ID o Nombre) pasó en cada zona.
-   **Salida**:
    -   Genera tablas de eficiencia.
    -   Crea gráficos de barras (usando `seaborn` y `matplotlib`) visualizando el tiempo por zona.
    -   Exporta los resultados a archivos Excel.

## Configuración y Datos

-   **`config.py`**: Archivo central para ajustar parámetros como el índice de la cámara, umbrales de confianza, rutas de bases de datos, etc.
-   **`data/zonas/zonas.json`**: Archivo JSON que contiene las coordenadas de las zonas de interés.
-   **`data/faces/`**: Directorio donde se deben colocar las carpetas con fotos de los empleados para que el sistema aprenda a reconocerlos (ej. `data/faces/Juan_Perez/foto1.jpg`).
