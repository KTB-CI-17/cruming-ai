from fastapi import FastAPI
from health import router as health_router

app = FastAPI()

# Health check endpoint 추가
app.include_router(health_router)

print('test')