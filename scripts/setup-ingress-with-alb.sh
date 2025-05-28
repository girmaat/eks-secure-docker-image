#!/bin/bash

set -euo pipefail

echo "Checking for AWS Load Balancer Controller..."

if ! kubectl get deployment -n kube-system aws-load-balancer-controller &>/dev/null; then
    echo "AWS Load Balancer Controller not found. Installing..."

    echo "Step 1: Add EKS chart repo (if not already added)..."
    helm repo add eks https://aws.github.io/eks-charts
    helm repo update

    echo "Step 2: Create IAM OIDC provider (manual step if not done)"
    echo "Please ensure you have created the OIDC provider and IRSA role manually."
    echo "See: https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html"

    echo "Step 3: Install AWS Load Balancer Controller (cluster-specific values required)..."
    echo "Replace <your-cluster-name> and <service-account-role-arn> before running the install command."

    cat <<EOF
# Example install command (do not run blindly):
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=<your-cluster-name> \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=<your-region> \
  --set vpcId=<your-vpc-id> \
  --set image.tag="v2.6.1"
EOF

    echo "Halting script here. Complete AWS Load Balancer Controller setup before re-running."
    exit 1
else
    echo "AWS Load Balancer Controller is installed."
fi

echo "Applying ingress.yaml to create ALB ingress resource..."
kubectl apply -f manifests/ingress.yaml

echo "Ingress applied. ALB provisioning may take a few minutes. Monitor with:"
echo "kubectl get ingress"
