# 빌드 스테이지
FROM python:3.10.11-slim AS builder

WORKDIR /app

# 빌드 도구만 builder 스테이지에 설치
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 가상환경 생성 및 활성화
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# 패키지 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 런타임 스테이지
FROM python:3.10.11-slim

WORKDIR /app

# 런타임에 필요한 라이브러리만 설치
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# 가상환경만 복사
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# 애플리케이션 복사
COPY app/ ./app/
COPY model/ ./model/

EXPOSE 8000
ENV PYTHONPATH=/app

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]