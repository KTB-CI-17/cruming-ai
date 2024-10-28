# Python 3.10.11 slim 이미지를 사용
FROM python:3.10.11-slim

# 작업 디렉토리 설정
WORKDIR /app

# Python 패키지 설치
COPY app/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# 애플리케이션 코드 전체 복사
COPY app /app/app

# 모델 파일 복사
COPY model /app/model

# 웹 서버 포트 노출
EXPOSE 8000

# PYTHONPATH 설정 (app 패키지 인식)
ENV PYTHONPATH=/app

# 서버 실행 (FastAPI 예시)
CMD ["uvicorn", "app.app:app", "--host", "0.0.0.0", "--port", "8000"]