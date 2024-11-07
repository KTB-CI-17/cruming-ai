# syntax=docker/dockerfile:1.3
FROM choiseu98/python3.10.11-slim-cruming:latest as builder

WORKDIR /app

ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip \
    /opt/venv/bin/pip install --upgrade pip setuptools wheel && \
    /opt/venv/bin/pip install -r requirements.txt

COPY app/ ./app/
COPY model/ ./model/

# 실행 환경용 이미지
FROM choiseu98/python3.10.11-slim-cruming:latest

WORKDIR /app

ENV PATH="/opt/venv/bin:$PATH"
ENV PYTHONPATH=/app

# 빌드 스테이지에서 파일 복사
COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /app /app

EXPOSE 8000

CMD ["/opt/venv/bin/uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]