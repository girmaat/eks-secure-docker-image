#!/bin/bash

set -euo pipefail

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
CLUSTER_NAME=$(aws eks list-clusters --query 'clusters[0]' --output text)
OIDC_URL=$(aws eks describe-cluster --name "$CLUSTER_NAME" --query "cluster.identity.oidc.issuer" --output text)
OIDC_HOSTPATH=$(echo $OIDC_URL | sed -e "s~^https://~~")

ROLE_NAME="eso-secrets-access-role"
POLICY_NAME="ESOSecretsAccess"
SERVICE_ACCOUNT_NAMESPACE="external-secrets"
SERVICE_ACCOUNT_NAME="eso-service-account"

echo "Creating trust policy..."
cat <<EOF > trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::$ACCOUNT_ID:oidc-provider/$OIDC_HOSTPATH"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "$OIDC_HOSTPATH:sub": "system:serviceaccount:$SERVICE_ACCOUNT_NAMESPACE:$SERVICE_ACCOUNT_NAME"
        }
      }
    }
  ]
}
EOF

echo "Creating IAM role: $ROLE_NAME"
aws iam create-role   --role-name $ROLE_NAME   --assume-role-policy-document file://trust-policy.json

echo "Attaching inline policy for SecretsManager access..."
aws iam put-role-policy   --role-name $ROLE_NAME   --policy-name $POLICY_NAME   --policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "secretsmanager:GetSecretValue"
        ],
        "Resource": "*"
      }
    ]
  }'

echo "Role created and policy attached."
echo "Use this role ARN in your Kubernetes ServiceAccount annotation:"
echo "   arn:aws:iam::$ACCOUNT_ID:role/$ROLE_NAME"
