# syntax=docker/dockerfile:1.3
# Step 1: 기본 이미지 가져오기
FROM choiseu98/python3.10.11-slim-cruming:latest

# Step 2: 작업 디렉토리 설정
WORKDIR /app

# Step 3: Python 경로 설정
ENV PATH="/opt/venv/bin:$PATH"
ENV PYTHONPATH=/app

# Step 4: 의존성 파일 복사 및 설치
COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r requirements.txt

# Step 5: 애플리케이션 코드와 모델 복사
COPY app/ ./app/
COPY model/ ./model/

# Step 6: 불필요한 파일 제거
RUN find /opt/venv -type d -name "__pycache__" -exec rm -r {} +

# Step 7: 포트 노출
EXPOSE 8000

# Step 8: 애플리케이션 실행 명령
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]