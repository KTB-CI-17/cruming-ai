from fastapi import FastAPI
from app.health import router as health_router  # 절대 경로로 수정

app = FastAPI()
app.include_router(health_router)