from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def root():
    return {"message": "Welcome to eks-secure-docker-image!"}

@app.get("/healthz")
def healthz():
    return {"status": "healthy"}

@app.get("/readyz")
def readyz():
    return {"status": "ready"}
