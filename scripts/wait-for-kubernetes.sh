#!/bin/bash

if [ ! -x "$KUBECTL" ]; then
  echo "$KUBECTL" not found or executable
  exit 1
fi
for ((i = 0; i < 30; i++)); do
  if [ ! -f "$KUBECONFIG" ]; then
    echo "$KUBECONFIG" not found.
    # Try for 15 minutes (30x30)
    sleep 30
  else
    break
  fi
done

# Wait for kubernetes to be ready before continuing
while :; do
  if ! $KUBECTL get nodes >/dev/null 2>&1; then
    # Be quiet when output is pointless
    sleep 20
  elif $KUBECTL get nodes >/dev/null 2>&1; then
    NODES=$($KUBECTL get nodes -o json 2>/dev/null | jq -r '.items[].metadata.name' | wc -l)
    NODES_READY=$($KUBECTL get nodes -o json 2>/dev/null | jq -r '.items[].status.conditions[] | select(.reason == "KubeletReady") | .type' | wc -l)
    if ((NODES_READY == NODES)); then
      break
    else
      sleep 5 && echo Waiting for Kubernetes nodes to be ready
    fi
  fi
done
