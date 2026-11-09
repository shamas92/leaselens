# LeaseLens backend — FastAPI (Python 3.12)
# Multi-stage: stage 1 installs Python dependencies into a venv,
# stage 2 is the slim runtime with the system tools the app shells out to.

# ---------- Stage 1: Python dependencies ----------
FROM python:3.12-slim AS deps

ENV PIP_NO_CACHE_DIR=1 \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /app
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# ---------- Stage 2: Runtime ----------
FROM python:3.12-slim AS runtime

# ffmpeg: walkthrough video handling; poppler-utils: PDF text extraction;
# tesseract-ocr (+ deu/eng language packs): OCR for photographed leases.
RUN apt-get update && apt-get install -y --no-install-recommends \
        ffmpeg \
        poppler-utils \
        tesseract-ocr \
        tesseract-ocr-deu \
        tesseract-ocr-eng \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /app
COPY --from=deps /opt/venv /opt/venv
COPY . .

RUN chmod +x docker-entrypoint.sh

EXPOSE 8000
ENTRYPOINT ["./docker-entrypoint.sh"]
