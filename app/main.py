import json
import logging
import os
import socket
from datetime import datetime, timezone

from fastapi import FastAPI, HTTPException


class JsonFormatter(logging.Formatter):
    def format(self, record: logging.LogRecord) -> str:
        return json.dumps({
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "level": record.levelname,
            "message": record.getMessage(),
            "service": "backend",
        })


handler = logging.StreamHandler()
handler.setFormatter(JsonFormatter())
logger = logging.getLogger("lab")
logger.handlers = [handler]
logger.setLevel(logging.INFO)

app = FastAPI(title="Linux Troubleshooting Lab")


@app.get("/")
def root() -> dict[str, str]:
    message = os.getenv("APP_MESSAGE")
    if not message:
        raise HTTPException(status_code=500, detail="APP_MESSAGE is missing")
    logger.info("root request served")
    return {"message": message, "hostname": socket.gethostname()}


@app.get("/health/live")
def live() -> dict[str, str]:
    return {"status": "alive"}


@app.get("/health/ready")
def ready() -> dict[str, str]:
    return {"status": "ready"}


@app.get("/version")
def version() -> dict[str, str]:
    return {"version": os.getenv("APP_VERSION", "unknown")}
