# Creación de Instaladores Nativos

Este documento explica, paso a paso y en lenguaje sencillo, cómo transformar tu código Python (`.py`) en un instalador profesional (de esos que tienen un asistente "Siguiente > Siguiente > Instalar") para que tus clientes puedan instalar el programa fácilmente en Windows sin necesidad de saber programación.

## ¿Qué es un Instalador Nativo?

Tus clientes no tienen instalado Python, ni las librerías complicadas de Inteligencia Artificial, ni saben usar la terminal de comandos. Un instalador nativo es un único archivo (ej. `Instalador_Oficina_Eficiencia.exe`) que contiene todo lo necesario para que el programa funcione al hacer doble clic.

---

## Paso 1: Empaquetado (Convertir Python a .exe)

Lo primero es convertir tus scripts sueltos en un único programa ejecutable.

1.  **Herramienta**: Usaremos una herramienta estándar llamada **PyInstaller**.
2.  **Proceso**:
    *   PyInstaller analiza tu código (`main.py`) y detecta automáticamente todas las librerías que usas (OpenCV, PyTorch, Pandas, etc.).
    *   Crea una "burbuja" o carpeta que contiene tu programa compilado junto con una versión mini de Python y todas esas librerías.
    *   **Resultado**: Obtienes una carpeta (o un solo archivo `.exe`) que puedes copiar a cualquier computadora con Windows y funcionará, incluso si esa computadora no tiene Python instalado.
3.  **Archivos Extra**: Debes indicarle a PyInstaller que incluya también tus archivos de configuración (`config.py`), los modelos de IA (`yolov8n.pt`) y la base de datos vacía, ya que él no puede adivinar que los necesitas si no están importados explícitamente en el código.

## Paso 2: Creación del Asistente de Instalación

Ahora que tienes el programa ejecutable, necesitas un asistente que lo coloque en la carpeta "Archivos de Programa", cree accesos directos en el Escritorio y configure todo.

1.  **Herramienta**: Recomendamos **Inno Setup** (es gratuito y muy popular en Windows).
2.  **El Script de Instalación**: Inno Setup usa un archivo de texto simple donde defines las reglas de tu instalador:
    *   **Nombre de la App**: "Sistema de Eficiencia v1.0"
    *   **Archivos a Copiar**: Le dices "toma todo lo que generó PyInstaller en el Paso 1 y cópialo a la computadora del cliente".
    *   **Accesos Directos**: Le dices "crea un icono en el Escritorio y otro en el Menú Inicio".
    *   **Licencia**: Puedes pegar aquí el texto de tu licencia de uso para que el usuario tenga que aceptar los términos antes de instalar.
3.  **Compilación**: Inno Setup lee esas instrucciones y genera un único archivo `setup.exe` profesional y comprimido.

## Paso 3: Firma Digital (Opcional pero Recomendado)

Si envías el `.exe` así nada más, Windows mostrará una alerta roja diciendo "Editor Desconocido" o "Windows protegió su PC", lo cual asusta a los clientes.

1.  **Certificado**: Para evitar esto, necesitas comprar un **Certificado de Firma de Código** (Code Signing Certificate) de una autoridad confiable.
2.  **Firma**: Usas una herramienta para "firmar" tu instalador con ese certificado.
3.  **Resultado**: Cuando el cliente abra el instalador, Windows mostrará un escudo azul y dirá "Editor Verificado: Tu Empresa S.A.", dando confianza y profesionalismo.

---

## Resumen del Flujo

1.  **Tú (Desarrollador)**: Escribes código en Python.
2.  **PyInstaller**: Empaqueta ese código + Python + Librerías en una carpeta ejecutable.
3.  **Inno Setup**: Toma esa carpeta y crea un archivo `setup.exe` con un asistente de instalación bonito.
4.  **Cliente**: Descarga `setup.exe`, hace doble clic, y el programa se instala en su computadora listo para usar.
