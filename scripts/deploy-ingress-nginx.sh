#!/bin/bash

set -euo pipefail

INGRESS_NAME="secure-api-ingress"
NAMESPACE="default"
DOMAIN="secure-api.local"

echo "Applying NGINX Ingress manifest..."
kubectl apply -f manifests/ingress-nginx.yaml

echo "Waiting for ingress to be created..."
sleep 5
kubectl get ingress $INGRESS_NAME -n $NAMESPACE

echo "Checking Ingress address (IP or hostname)..."
INGRESS_IP=$(kubectl get ingress $INGRESS_NAME -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
INGRESS_HOSTNAME=$(kubectl get ingress $INGRESS_NAME -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

if [ -n "$INGRESS_IP" ]; then
  echo "Ingress is accessible at IP: $INGRESS_IP"
  echo "If using local dev, map this IP to $DOMAIN in /etc/hosts"
elif [ -n "$INGRESS_HOSTNAME" ]; then
  echo "Ingress is accessible at hostname: $INGRESS_HOSTNAME"
else
  echo "Ingress address not available yet. Try again in a few moments."
  exit 1
fi

echo "Testing HTTP access..."
curl -s http://$DOMAIN/readyz || echo "HTTP request failed."

echo "Testing HTTPS (TLS) access (if cert-manager is configured)..."
curl -s -k https://$DOMAIN/readyz || echo "HTTPS request failed."

echo "Done. Make sure your DNS or /etc/hosts routes $DOMAIN to the ingress address."
