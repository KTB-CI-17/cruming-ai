# syntax=docker/dockerfile:1.3
FROM choiseu98/python3.10.11-slim-cruming:latest

WORKDIR /app

ENV PATH="/opt/venv/bin:$PATH"
ENV PYTHONPATH=/app

# 의존성 설치
COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --upgrade pip setuptools wheel && \
    pip install -r requirements.txt && \
    rm -rf /root/.cache/pip

# 캐시 파일 제거
RUN find /opt/venv -type d -name "__pycache__" -exec rm -r {} +

# 애플리케이션 코드 복사
COPY app/ ./app/
COPY model/ ./model/

EXPOSE 8000

# 애플리케이션 실행
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
