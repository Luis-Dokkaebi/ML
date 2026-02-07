# src/utils/captura_frame.py
import cv2

cap = cv2.VideoCapture(0)
ret, frame = cap.read()
cv2.imwrite("data/zonas/frame_referencia.jpg", frame)
cap.release()
