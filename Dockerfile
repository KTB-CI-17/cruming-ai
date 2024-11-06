FROM python:3.10.11-slim

WORKDIR /app

# apt-get 최적화 및 필수 패키지만 특정 버전으로 설치
RUN apt-get update && apt-get install -y --no-install-recommends \
   build-essential=12.* \
   libgl1-mesa-glx=20.* \
   libglib2.0-0=2.* \
   libsm6=2:* \
   libxext6=2:* \
   libxrender-dev=1:* \
   libgomp1=10.* \
   && apt-get clean \
   && rm -rf /var/lib/apt/lists/* \
   && python -m venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

# pip 설치 최적화
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
   pip install --no-cache-dir -r requirements.txt

# 애플리케이션 파일 복사
COPY app/ ./app/
COPY model/ ./model/

EXPOSE 8000
ENV PYTHONPATH=/app

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]