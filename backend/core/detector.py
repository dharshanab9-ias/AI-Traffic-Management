import os
import cv2
import torch
from ultralytics import YOLO

# Comprehensive Indian & Standard COCO vehicle and pedestrian class mappings
TARGET_CLASSES = {
    2: "car",
    3: "motorcycle",
    5: "bus",
    7: "truck",
    1: "bicycle",
    0: "pedestrian"
}

class VehicleDetector:
    def __init__(self, model_name: str = "yolov8n.pt", conf_thresh: float = 0.30):
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        self.conf_thresh = conf_thresh
        self.conf_threshold = conf_thresh
        self.iou_threshold = 0.45
        self.current_model_name = model_name
        self._load_model(model_name)

    def _load_model(self, model_name: str):
        base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        candidate_paths = [
            model_name,
            os.path.join(base_dir, model_name),
            os.path.join(base_dir, "models", model_name)
        ]
        target_path = model_name
        for p in candidate_paths:
            if os.path.exists(p):
                target_path = p
                break
        else:
            local_nano = os.path.join(base_dir, "yolov8n.pt")
            if os.path.exists(local_nano):
                target_path = local_nano
                print(f"[VehicleDetector] Requested model not found locally; falling back to bundled {local_nano}")

        print(f"[VehicleDetector] Loading high-speed model {target_path} on {self.device.upper()}...")
        self.model = YOLO(target_path)
        self.current_model_name = os.path.basename(target_path)

    def switch_model(self, model_name: str) -> str:
        """Hot-swaps the YOLO model weights on the fly"""
        self._load_model(model_name)
        return self.current_model_name

    def detect(self, frame):
        """
        Runs high-speed object detection directly on frame (1280x720) with YOLOv8.
        Provides 1:1 pixel-accurate coordinate alignment and authentic Indian multi-class vehicle categorization:
        - Car: Sedans, Hatchbacks, SUVs
        - Two-Wheeler: Motorcycles, Scooters
        - Auto-Rickshaw: 3-Wheeled commercial vehicles
        - Bus: Transit buses, private coaches
        - Truck: Heavy freight, haulers, cargo lorries
        - Pedestrian: Vulnerable road users & school children
        """
        if frame is None:
            return []

        results = self.model.predict(
            source=frame,
            imgsz=640,
            conf=self.conf_thresh,
            device=self.device,
            verbose=False,
            classes=list(TARGET_CLASSES.keys())
        )
        
        detections = []
        if not results:
            return detections

        for r in results:
            boxes = r.boxes
            for box in boxes:
                cls_id = int(box.cls[0].item())
                conf = float(box.conf[0].item())
                s_coords = box.xyxy[0].cpu().numpy().astype(int).tolist()

                x1, y1, x2, y2 = s_coords[0], s_coords[1], s_coords[2], s_coords[3]
                bw = max(1, x2 - x1)
                bh = max(1, y2 - y1)
                aspect_ratio = bw / float(bh)
                area = bw * bh

                # Authentic COCO & Indian Traffic Categorization
                if cls_id == 2:
                    # Car: Check for compact upright 3-wheeler profile (Auto-Rickshaw)
                    if 0.75 <= aspect_ratio <= 1.05 and 1500 < area < 7500:
                        class_name = "auto_rickshaw"
                    else:
                        class_name = "car"
                elif cls_id == 3:
                    class_name = "two_wheeler"
                elif cls_id == 5:
                    class_name = "bus"
                elif cls_id == 7:
                    class_name = "truck"
                elif cls_id == 1:
                    class_name = "bicycle"
                elif cls_id == 0:
                    # Distinguish school-age children by relative height
                    if bh < 44 or (aspect_ratio > 0.60 and bh < 58):
                        class_name = "child"
                    else:
                        class_name = "pedestrian"
                else:
                    class_name = "car"

                detections.append({
                    "bbox": [x1, y1, x2, y2],
                    "class_name": class_name,
                    "confidence": round(conf, 3),
                    "class_id": cls_id
                })
                
        return detections
