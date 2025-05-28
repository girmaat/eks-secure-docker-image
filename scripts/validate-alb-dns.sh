#!/bin/bash

set -euo pipefail

INGRESS_NAME="secure-api-ingress"
NAMESPACE="default"

echo "Checking if Ingress '$INGRESS_NAME' exists..."
if ! kubectl get ingress $INGRESS_NAME -n $NAMESPACE &>/dev/null; then
  echo "Ingress $INGRESS_NAME not found in namespace $NAMESPACE."
  exit 1
fi

echo "Ingress resource found. Retrieving ALB hostname..."
ALB_HOSTNAME=$(kubectl get ingress $INGRESS_NAME -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

if [ -z "$ALB_HOSTNAME" ]; then
  echo "ALB is still provisioning. Try again in a few minutes."
  exit 1
fi

echo "ALB Hostname: $ALB_HOSTNAME"

echo "Performing DNS lookup..."
nslookup $ALB_HOSTNAME || dig +short $ALB_HOSTNAME

echo "Testing HTTPS endpoint..."
curl -k --max-time 5 https://$ALB_HOSTNAME/readyz || {
  echo "HTTPS probe failed. The ALB may not be ready or cert may not be valid yet."
  exit 1
}

echo "ALB and DNS appear to be working. Application is accessible at:"
echo "https://$ALB_HOSTNAME/"
