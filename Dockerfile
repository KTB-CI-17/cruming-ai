# syntax=docker/dockerfile:1.3
FROM choiseu98/python3.10.11-slim-cruming:latest as builder

WORKDIR /app

ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --upgrade pip setuptools wheel && \
    pip install -r requirements.txt

COPY app/ ./app/
COPY model/ ./model/

FROM choiseu98/python3.10.11-slim-cruming:latest

WORKDIR /app

ENV PATH="/opt/venv/bin:$PATH"
ENV PYTHONPATH=/app

COPY --from=builder /app /app

EXPOSE 8000

CMD ["/opt/venv/bin/uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]