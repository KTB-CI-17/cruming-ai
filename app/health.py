from fastapi import APIRouter
import os

router = APIRouter()

@router.get("/health")
async def health_check():
    return {"status": "ok", "model_loaded": os.path.exists("/app/model/model.bin")}