from fastapi import FastAPI, File, UploadFile, HTTPException
from app.detector import HoldDetector
from app.health import router as health_router

app = FastAPI(
    title="Hold Detection API",
    description="클라이밍 홀드 감지를 위한 API",
    version="1.0.0"
)

# 헬스 체크 라우터 추가
app.include_router(health_router)

# 전역 변수로 detector 초기화
detector = HoldDetector()

@app.post("/ai/detect", summary="홀드 감지")
async def detect_holds(file: UploadFile = File(...)):
    """
    이미지에서 홀드를 감지합니다.
    """
    try:
        result = await detector.detect(file)
        if "error" in result:
            print("error")
            raise HTTPException(status_code=500, detail=result["error"])
        return result
    except Exception as e:
        print("exception")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)