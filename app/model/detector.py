from ultralytics import YOLO
from PIL import Image
from pathlib import Path
import io


class HoldDetector:
    def __init__(self):
        model_path = Path(__file__).parent / "weights" / "Ndatayolov5.pt"
        self.model = YOLO(str(model_path))

    async def detect(self, image_file) -> dict:
        """
        이미지에서 홀드를 감지합니다.
        """
        try:
            # 이미지 읽기
            contents = await image_file.read()
            image = Image.open(io.BytesIO(contents))

            # 객체 감지 수행
            results = self.model(image)

            # 결과 처리
            holds = []
            for r in results[0].boxes.data:
                x1, y1, x2, y2, conf, cls = r
                hold_info = {
                    "class": results[0].names[int(cls)],
                    "confidence": float(conf),
                    "coordinates": {
                        "x1": float(x1),
                        "y1": float(y1),
                        "x2": float(x2),
                        "y2": float(y2)
                    }
                }
                holds.append(hold_info)

            return {"holds": holds}

        except Exception as e:
            return {"error": str(e)}