# src/main.py

import cv2
from config import config
from detection.person_detector import PersonDetector
from tracking.person_tracker import PersonTracker
from zones.zone_checker import ZoneChecker
from storage.database_manager import DatabaseManager

def get_bbox_center(xyxy):
    x1, y1, x2, y2 = xyxy
    center_x = (x1 + x2) / 2
    center_y = (y1 + y2) / 2
    return center_x, center_y

def start_video_stream():
    # Selección de fuente de video
    if config.MODE == 'local':
        video_source = config.LOCAL_CAMERA_INDEX
    else:
        video_source = config.REMOTE_CAMERA_URL

    cap = cv2.VideoCapture(video_source)

    # Inicializamos los módulos
    detector = PersonDetector(confidence_threshold=config.CONFIDENCE_THRESHOLD)
    tracker = PersonTracker()
    zone_checker = ZoneChecker(zones_path="data/zonas/zonas.json")
    db_manager = DatabaseManager(db_path=config.LOCAL_DB_PATH)

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        # Detección y tracking
        detections = detector.detect(frame)
        tracked_detections = tracker.update(detections)

        # Procesamos cada persona detectada
        for xyxy, track_id in zip(tracked_detections.xyxy, tracked_detections.tracker_id):
            x1, y1, x2, y2 = map(int, xyxy)
            cx, cy = get_bbox_center(xyxy)

            results = zone_checker.check(cx, cy)
            for zone_name, inside in results.items():
                inside_zone = int(inside)
                
                # Registramos en la base de datos
                db_manager.insert_record(
                    track_id=int(track_id),
                    x=cx,
                    y=cy,
                    zone=zone_name,
                    inside_zone=inside_zone
                )

                # Dibujamos bounding box
                color = (0, 255, 0) if inside_zone else (0, 0, 255)
                cv2.rectangle(frame, (x1, y1), (x2, y2), color, 2)
                cv2.putText(frame, f"ID:{track_id} {zone_name} {'IN' if inside_zone else 'OUT'}",
                            (x1, y1-10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)

        cv2.imshow("Sistema completo en acción", frame)

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    start_video_stream()
