from ultralytics import YOLO
from PIL import Image
from pathlib import Path
import io


class HoldDetector:
    def __init__(self):
        model_path = Path(__file__).parent.parent / "model" / "weights" / "Ndatayolov11-seg.pt"
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
            # results[0].boxes.data와 results[0].masks.xy는 인덱스로 일치
            for i, box_data in enumerate(results[0].boxes.data):
                x1, y1, x2, y2, conf, cls = box_data
                cls = int(cls)

                # 클래스가 0인 경우만 polygon 좌표를 전달
                if cls == 0:
                    # polygon 좌표 정보는 results[0].masks.xy[i]에 있습니다.
                    polygon_coords = results[0].masks.xy[i].tolist()

                    hold_info = {
                        "class": results[0].names[cls],
                        "confidence": float(conf),
                        "polygon": polygon_coords
                    }
                    holds.append(hold_info)

            return {"holds": holds}

        except Exception as e:
            return {"error": str(e)}
