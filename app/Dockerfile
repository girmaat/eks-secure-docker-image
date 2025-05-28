# ────────🔧 BUILD STAGE ────────
FROM python:3.11-slim AS builder

WORKDIR /app

# Create and activate a virtual environment
RUN python -m venv /venv

# Install deps inside the venv
COPY requirements.txt .
RUN /venv/bin/pip install --no-cache-dir -r requirements.txt

# ────────🔐 RUNTIME STAGE ────────
FROM python:3.11-slim

# Add non-root user
RUN adduser --disabled-password appuser
USER appuser

WORKDIR /app

# Copy app code and venv
COPY --chown=appuser:appuser . .
COPY --from=builder /venv /venv

# Activate virtualenv
ENV PATH="/venv/bin:$PATH"

# OCI Labels
ARG BUILD_DATE="unset"
LABEL org.opencontainers.image.source="https://github.com/yourorg/eks-secure-docker-image"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.authors="you@example.com"

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
