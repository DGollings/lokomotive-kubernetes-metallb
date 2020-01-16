apiVersion: projectcalico.org/v3
kind: BGPPeer
metadata:
  name: ${HOSTNAME}
spec:
  peerIP: ${PEER_IP}
  node: ${HOSTNAME}
  asNumber: 65530