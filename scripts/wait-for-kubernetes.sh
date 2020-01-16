#!/bin/bash

# Wait for kubernetes to be ready before continuing
while ! $KUBECTL --kubeconfig $KUBECONFIG get nodes 2>/dev/null | grep -v NotReady; do
    sleep 10 && echo WAITING FOR KUBERNETES
done
