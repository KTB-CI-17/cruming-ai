import sys
from pathlib import Path
import torch
import numpy as np
from PIL import Image
import io

# 현재 파일의 경로
FILE = Path(__file__).resolve()
# YOLOv5 디렉토리 경로 설정
YOLOV5_DIR = FILE.parents[1] / 'cruming' / 'Lib' / 'site-packages' / 'yolov5'
sys.path.append(str(YOLOV5_DIR))  # YOLOv5 모듈 경로 추가

print(f"YOLOV5_DIR: {YOLOV5_DIR}")
print(f"Directory exists: {YOLOV5_DIR.exists()}")
print("sys.path:", sys.path)

from models.common import DetectMultiBackend
from utils.general import non_max_suppression, scale_boxes
from utils.augmentations import letterbox

class HoldDetector:
    def __init__(self):
        # 모델 경로 설정
        model_path = FILE.parents[1] / "model" / "weights" / "Ndatayolov5n.pt"
        print(f"Loading model from: {model_path}")
        # 디바이스 설정 (GPU 사용 가능 시 GPU 사용)
        device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        # 모델 로드
        self.model = DetectMultiBackend(str(model_path), device=device)
        print("Model loaded successfully")
        self.stride = self.model.stride
        self.names = self.model.names
        self.img_size = 640  # YOLOv5n의 기본 이미지 크기 (직접 설정)

    async def detect(self, image_file) -> dict:
        """
        이미지에서 홀드를 감지합니다.
        """
        count = 0
        try:
            print("Reading image file")
            # 이미지 읽기
            contents = await image_file.read()
            image = Image.open(io.BytesIO(contents)).convert('RGB')
            img0 = np.array(image)
            print(f"Image shape: {img0.shape}")

            # 전처리
            print(f"Preprocessing with img_size: {self.img_size}")
            img = letterbox(img0, self.img_size, stride=self.stride, auto=True)[0]
            img = img.transpose((2, 0, 1))  # HWC to CHW
            img = np.ascontiguousarray(img)
            print(f"Preprocessed image shape: {img.shape}")

            # 추론
            print("Running inference")
            img = torch.from_numpy(img).to(self.model.device)
            img = img.float() / 255.0  # 0~1 사이로 정규화
            if img.ndimension() == 3:
                img = img.unsqueeze(0)
            print(f"Tensor shape: {img.shape}")

            pred = self.model(img)
            print("Inference done, applying NMS")
            pred = non_max_suppression(pred, conf_thres=0.25, iou_thres=0.45)
            print(f"Number of detections: {len(pred)}")

            # 결과 처리
            holds = []
            for det in pred:
                if len(det):
                    # Rescale boxes from img_size to img0 size
                    det[:, :4] = scale_boxes(img.shape[2:], det[:, :4], img0.shape).round()
                    print(f"Scaled boxes: {det[:, :4]}")

                    for *xyxy, conf, cls in det:
                        x1, y1, x2, y2 = map(float, xyxy)
                        hold_info = {
                            "class": self.names[int(cls)],
                            "confidence": float(conf),
                            "coordinates": {
                                "x1": x1,
                                "y1": y1,
                                "x2": x2,
                                "y2": y2
                            }
                        }
                        holds.append(hold_info)

            # 감지된 홀드의 개수 출력
            num_holds = len(holds)
            print(f"Number of detected holds: {num_holds}")

            print(f"Detection results: {holds}")
            return {"holds": holds}

        except Exception as e:
            print(f"Error in detect: {e}")
            return {"error": str(e)}
