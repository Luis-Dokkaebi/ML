# src/detection/person_detector.py

from ultralytics import YOLO
import numpy as np
import supervision as sv

class PersonDetector:
    def __init__(self, model_path="models/yolov8/yolov8n.pt", confidence_threshold=0.4):
        self.model = YOLO(model_path)
        self.confidence_threshold = confidence_threshold

    def detect(self, frame):
        # Infer on frame
        results = self.model(frame)[0]
        
        # Convert to supervision detections
        detections = sv.Detections.from_ultralytics(results)
        
        # Filter classes: 0 is person, 67 is cell phone (in COCO)
        mask = np.isin(detections.class_id, [0, 67])
        detections = detections[mask]
        
        # Filter by confidence
        detections = detections[detections.confidence > self.confidence_threshold]

        return detections

