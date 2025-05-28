#!/bin/bash

set -e

echo "Step 1: Launching a CPU load generator using busybox..."
kubectl run cpu-loader --image=busybox --restart=Never -- /bin/sh -c "while true; do :; done"

echo "CPU load generator started (infinite loop consuming CPU)."
echo

echo "Step 2: Watching current pod CPU usage (via Metrics Server)..."
echo "NOTE: Press Ctrl+C to stop watching once values appear."
sleep 5
kubectl top pods

echo
echo "Step 3: Watching Horizontal Pod Autoscaler behavior..."
echo "This will show whether the app scales up based on CPU usage..."
echo "NOTE: Press Ctrl+C to stop watching when enough data is seen."
sleep 3
kubectl get hpa secure-api-hpa --watch

# Final cleanup (uncomment if you want auto-delete after observation)
echo "Cleaning up load generator pod..."
kubectl delete pod cpu-loader

echo "🎉 Done. Your HPA should have scaled the deployment if CPU thresholds were crossed."
