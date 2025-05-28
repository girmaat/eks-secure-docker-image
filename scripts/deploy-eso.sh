#!/bin/bash

set -euo pipefail

echo "Applying ESO service account (IRSA)..."
kubectl apply -f eso/eso-service-account.yaml

echo "Applying ClusterSecretStore..."
kubectl apply -f eso/clustersecretstore.yaml

echo "Applying ExternalSecret..."
kubectl apply -f eso/externalsecret.yaml

echo "Waiting for K8s secret to be created..."
for i in {1..10}; do
  if kubectl get secret db-secret -n secure-api > /dev/null 2>&1; then
    echo "Kubernetes secret 'db-secret' has been created!"
    break
  fi
  sleep 3
done

echo "Decoding and displaying secret value:"
kubectl get secret db-secret -n secure-api -o jsonpath='{.data.password}' | base64 -d && echo

echo "External Secrets Operator deployment and validation completed."
