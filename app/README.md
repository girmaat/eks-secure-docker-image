# app/

This is a minimal FastAPI service used to demonstrate secure Docker image practices and Kubernetes deployment readiness.

## Endpoints

- `/` - Root message
- `/healthz` - Liveness probe target
- `/readyz` - Readiness probe target

## How to Run Locally

```bash
pip install -r requirements.txt
uvicorn main:app --reload
