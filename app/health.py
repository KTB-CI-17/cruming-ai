from fastapi import APIRouter
import os
from pathlib import Path

router = APIRouter()

@router.get("/health")
async def health_check():
    model_path = Path(__file__).parent.parent / "model" / "weights" / "Ndatayolov5.pt"
    return {
        "status": "ok",
        "model_loaded": os.path.exists(model_path)
    }