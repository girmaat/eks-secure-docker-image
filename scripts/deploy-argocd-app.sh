#!/bin/bash

set -euo pipefail

APP_NAME="secure-api"
NAMESPACE="argocd"
DEST_NAMESPACE="secure-api"
REPO_URL="https://github.com/<your-username>/eks-secure-docker-image"
REPO_PATH="helm/secure-api"
REVISION="main"

echo "Creating ArgoCD Application manifest..."

mkdir -p argocd
cat <<EOF > argocd/${APP_NAME}-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${APP_NAME}
  namespace: ${NAMESPACE}
spec:
  project: default
  source:
    repoURL: ${REPO_URL}
    targetRevision: ${REVISION}
    path: ${REPO_PATH}
    helm:
      valueFiles:
        - values.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: ${DEST_NAMESPACE}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
EOF

echo "Applying ArgoCD Application..."
kubectl apply -f argocd/${APP_NAME}-app.yaml

echo "Waiting for ArgoCD application to sync..."
for i in {1..30}; do
  SYNC_STATUS=$(kubectl get application ${APP_NAME} -n ${NAMESPACE} -o jsonpath="{.status.sync.status}" 2>/dev/null || echo "Pending")
  HEALTH_STATUS=$(kubectl get application ${APP_NAME} -n ${NAMESPACE} -o jsonpath="{.status.health.status}" 2>/dev/null || echo "Unknown")

  echo "Sync: ${SYNC_STATUS} | Health: ${HEALTH_STATUS}"

  if [[ "$SYNC_STATUS" == "Synced" && "$HEALTH_STATUS" == "Healthy" ]]; then
    echo "Application is successfully synced and healthy."
    break
  fi

  if [[ $i -eq 30 ]]; then
    echo "Application failed to sync after waiting 60 seconds."
    exit 1
  fi

  sleep 2
done

echo "Port-forwarding ArgoCD dashboard to https://localhost:8080 ..."
kubectl port-forward svc/argocd-server -n ${NAMESPACE} 8080:443 &

echo "ArgoCD login info:"
echo "Username: admin"
echo -n "Password: "
kubectl -n ${NAMESPACE} get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo
