#!/bin/bash

set -euo pipefail

NAMESPACE="ingress-nginx"
RELEASE_NAME="nginx-ingress"

echo "🧹 Uninstalling NGINX Ingress Controller..."
helm uninstall $RELEASE_NAME -n $NAMESPACE

echo "🧼 Deleting namespace '$NAMESPACE'..."
kubectl delete namespace $NAMESPACE

echo "✅ NGINX Ingress Controller has been fully removed."
