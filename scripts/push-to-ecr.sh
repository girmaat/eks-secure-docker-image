#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Set variables (replace placeholders with real values)
AWS_ACCOUNT_ID="<your-account-id>"
AWS_REGION="<your-region>"
REPO_NAME="secure-image"
GIT_SHA=$(git rev-parse --short HEAD)

ECR_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME"

echo "Step 1: Logging into Amazon ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_URI
echo "Logged in to ECR: $ECR_URI"

echo "Step 2: Tagging local image with Git SHA ($GIT_SHA)..."
docker tag secure-image:$GIT_SHA $ECR_URI:$GIT_SHA
echo "Image tagged as: $ECR_URI:$GIT_SHA"

echo "Step 3: Pushing image to ECR..."
docker push $ECR_URI:$GIT_SHA
echo "Image pushed successfully: $ECR_URI:$GIT_SHA"

echo "Done! Your image is now in Amazon ECR and ready for deployment."