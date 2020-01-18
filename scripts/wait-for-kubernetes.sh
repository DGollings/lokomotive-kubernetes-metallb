#!/bin/bash

if [ ! -x $KUBECTL ]; then
  echo $KUBECTL not found or executable
fi
if [ ! -f $KUBECONFIG ]; then
  echo $KUBECONFIG not found
fi

# Wait for kubernetes to be ready before continuing
while ! $KUBECTL --kubeconfig $KUBECONFIG get nodes 2>/dev/null | grep -v NotReady; do
  # Be quiet when output is pointless
  if $KUBECTL --kubeconfig $KUBECONFIG get nodes 2>/dev/null | grep 'no such host'; then
    sleep 20
  # but start announcing yourself when nodes are getting ready
  elif ! $KUBECTL --kubeconfig $KUBECONFIG get nodes 2>/dev/null | grep -v NotReady; then
    sleep 5 && echo Waiting for Kubernetes nodes to be ready
  fi
done
