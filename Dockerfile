# Python 3.10.11 slim 이미지를 사용
FROM python:3.10.11-slim

# 작업 디렉토리 설정
WORKDIR /app

# 필요한 시스템 라이브러리 설치
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Python 패키지 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 애플리케이션 코드 복사
COPY app/ ./app/

# 모델 디렉토리 복사
COPY model/ ./model/

# 웹 서버 포트 노출
EXPOSE 8000

# PYTHONPATH 설정
ENV PYTHONPATH=/app

# 서버 실행
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]