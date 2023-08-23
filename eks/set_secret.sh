#!/bin/bash

set -ex

PROXY_URL=$(terraform output -raw proxy_config| base64 -w 0)
NO_PROXY="localhost,127.0.0.1,kubernetes.default.svc.cluster.local,kubernetes.default.svc"
NO_PROXY_URL=$(echo -n $NO_PROXY | base64 -w 0)


cat << EOF >  /tmp/proxy-config-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: proxy-config
  namespace: default
type: Opaque
immutable: true
data:
  httpProxy: $PROXY_URL
  httpsProxy: $PROXY_URL
  noProxy: $NO_PROXY_URL
EOF

kubectl apply -f /tmp/proxy-config-secret.yaml
