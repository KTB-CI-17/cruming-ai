# syntax=docker/dockerfile:1.3
FROM choiseu98/python3.10.11-slim-cruming:latest

WORKDIR /app

ENV PATH="/opt/venv/bin:$PATH"
ENV PYTHONPATH=/app

# 의존성 설치
COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip \
    /opt/venv/bin/pip install --upgrade pip setuptools wheel && \
    /opt/venv/bin/pip install -r requirements.txt

# 애플리케이션 코드 복사
COPY app/ ./app/
COPY model/ ./model/

EXPOSE 8000

# 애플리케이션 실행
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
