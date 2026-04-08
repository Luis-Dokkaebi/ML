import cv2
import queue
import threading
import time
from typing import Tuple, Any
import numpy as np

class CameraWorker(threading.Thread):
    def __init__(self, camera_id: int | str, frame_queue: queue.Queue, model: Any, fps_limit: int = 15):
        super().__init__(daemon=True) # El hilo muere al cerrar la app
        self.camera_id = camera_id
        self.frame_queue = frame_queue
        self.model = model
        self.fps_limit = fps_limit
        self.running = False
        self._delay = 1.0 / self.fps_limit

    def run(self):
        self.running = True
        if isinstance(self.camera_id, int):
            cap = cv2.VideoCapture(self.camera_id, cv2.CAP_DSHOW)
            if not cap.isOpened():
                cap = cv2.VideoCapture(self.camera_id)
        else:
            cap = cv2.VideoCapture(self.camera_id)
        
        # Fallback de autodescubrimiento B2B
        if not cap.isOpened():
            print(f"[VMS] Cámara {self.camera_id} falló. Intentando autodescubrimiento...")
            for idx in [0, 1, 2]:
                cap = cv2.VideoCapture(idx, cv2.CAP_DSHOW)
                if not cap.isOpened():
                    cap = cv2.VideoCapture(idx)
                if cap.isOpened():
                    print(f"[VMS] Cámara {idx} de respaldo conectada exitosamente.")
                    self.camera_id = idx
                    break
                    
        # Optimizacion OpenCV B2B: Forzar resolucion (opcional)
        # cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
        # cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)

        while self.running:
            start_time = time.time()
            ret, frame = cap.read()
            
            if not ret or frame is None or frame.size == 0:
                # Log de reconexion en entorno Enterprise (ej. RTSP perdido)
                time.sleep(2.0)
                if isinstance(self.camera_id, int):
                    cap = cv2.VideoCapture(self.camera_id, cv2.CAP_DSHOW)
                    if not cap.isOpened():
                        cap = cv2.VideoCapture(self.camera_id)
                else:
                    cap = cv2.VideoCapture(self.camera_id)
                continue

            # Inferencia YOLOv8
            results = self.model(frame, verbose=False)
            annotated_frame = results[0].plot() # numpy array (BGR)
            
            # --- DROP FRAME PROTOCOL (Anti-Memory Leak) ---
            try:
                # Intenta encolar sin bloquear. Si esta llena (UI retardada), entra al except
                self.frame_queue.put_nowait((self.camera_id, annotated_frame))
            except queue.Full:
                # Se descarta este frame para que la memoria no colapse
                pass 
                
            # Limitar FPS para ahorrar CPU (Artificial Throttle)
            elapsed_time = time.time() - start_time
            time_to_wait = self._delay - elapsed_time
            if time_to_wait > 0:
                time.sleep(time_to_wait)
                
        cap.release()

    def stop(self):
        self.running = False
