# syntax=docker/dockerfile:1.3
FROM python:3.10.11-slim as builder

WORKDIR /app

# venv 생성 및 경로 설정
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

COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip \
    /opt/venv/bin/pip install --upgrade pip setuptools wheel && \
    /opt/venv/bin/pip install -r requirements.txt

COPY app/ ./app/
COPY model/ ./model/

# 실행 환경용 이미지
FROM python:3.10.11-slim

WORKDIR /app

# 필수 패키지 설치 및 venv 설정
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
ENV PYTHONPATH=/app

# 빌드 스테이지에서 파일 복사
COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /app /app

EXPOSE 8000

CMD ["/opt/venv/bin/uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]