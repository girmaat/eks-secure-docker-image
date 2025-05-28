# eks-secure-docker-image

CI/CD pipeline to build, scan, tag, and deploy containerized microservices to Amazon EKS via GitOps.

---

## Project Overview

This project demonstrates a fully automated, secure deployment workflow using:

- ✅ Docker best practices (multistage, non-root, minimal images)
- ✅ CI/CD with GitHub Actions and ECR
- ✅ Image scanning via Trivy and Dive
- ✅ Helm charts for Kubernetes deployment
- ✅ GitOps via ArgoCD
- ✅ Runtime policies using Pod Security Admission and OPA Gatekeeper
- ✅ Secret management with External Secrets Operator and AWS Secrets Manager

---

## Architecture

```text
Dev ➜ GitHub ➜ GitHub Actions ─┬─➤ Trivy Scan
                              ├─➤ Build, Tag, Push to ECR
                              └─➤ Update Helm values.yaml (SHA tag)
                                                 ↓
                                             ArgoCD Sync
                                                 ↓
                                     Amazon EKS (via Helm Chart)
                                                 ↓
                                 PSA, HPA, Gatekeeper, ESO, TLS
```

---

## Components

### Dockerfile
- Multi-stage build
- Runs as non-root
- Adds OCI-compliant labels
- Final image ≤ 100MB

### GitHub Actions
- Lint, scan, build, tag images
- Push to ECR with unique Git SHA tags
- Auto-update Helm `values.yaml` for ArgoCD

### Kubernetes (via Helm)
- `deployment.yaml`, `service.yaml`, `hpa.yaml`, `ingress.yaml`
- ArgoCD watches `helm/secure-api/` and deploys automatically

### ESO + IRSA
- ExternalSecret pulls `db-password` from AWS Secrets Manager
- IAM role bound via IRSA to limit access

---

## Security Enhancements

| Feature | Description |
|--------|-------------|
| PSA | Namespace label: `restricted` profile |
| Gatekeeper | Disallows `:latest`, enforces securityContext |
| ESO | No plaintext secrets in Git or manifests |
| Trivy | Blocks image builds with known CVEs |
| Dive | Layer inspection to reduce bloat and risk |

---

## Local Testing

```bash
docker build -t secure-image:$(git rev-parse --short HEAD) .
docker run -p 8000:8000 secure-image:<sha>
curl http://localhost:8000/readyz
```

---

## Deploy via ArgoCD

```bash
kubectl apply -f argocd/secure-api-app.yaml
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

---
