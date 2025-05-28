#!/bin/bash

set -euo pipefail

NAMESPACE="ingress-nginx"
RELEASE_NAME="nginx-ingress"

echo "Adding NGINX Ingress Helm repo..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

echo "Installing NGINX Ingress Controller in namespace '$NAMESPACE'..."
helm install $RELEASE_NAME ingress-nginx/ingress-nginx --namespace $NAMESPACE --create-namespace

echo "Waiting for ingress controller pods to be ready..."
kubectl rollout status deployment/${RELEASE_NAME}-controller -n $NAMESPACE

echo "NGINX Ingress Controller installed and running."
kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=ingress-nginx
