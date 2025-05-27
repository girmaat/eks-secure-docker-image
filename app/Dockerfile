# ────────BUILD STAGE ────────
FROM python:3.11-slim AS builder

WORKDIR /app

# Install pip packages
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# ────────RUNTIME STAGE ────────
FROM python:3.11-alpine

# Add a non-root user
RUN adduser -D appuser
USER appuser

WORKDIR /app

# Copy only necessary files from builder
COPY --from=builder /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH

# Copy application code
COPY --chown=appuser:appuser . .

# Optional: Add labels for metadata (OCI standard)
LABEL org.opencontainers.image.source="https://github.com/yourorg/eks-secure-docker-image"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.authors="you@example.com"

# Expose port for uvicorn
EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
