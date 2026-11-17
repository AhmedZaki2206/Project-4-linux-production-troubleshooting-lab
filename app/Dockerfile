FROM python:3.12-slim AS builder
WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.12-slim
RUN groupadd --system app && useradd --system --gid app --home /app app
COPY --from=builder /install /usr/local
WORKDIR /app
COPY --chown=app:app main.py .
USER app
EXPOSE 8000
HEALTHCHECK --interval=10s --timeout=3s --retries=3 CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health/ready')"
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
