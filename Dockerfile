FROM choiseu98/python3.10.11-slim-cruming:latest

WORKDIR /app

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
