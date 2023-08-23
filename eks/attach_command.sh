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

KUBECTL_CONTEXT=$(kubectl config current-context)
ISSUER_URL=$(terraform output -raw get_issuerURL)
PROJECT_NUMBER=$(gcloud projects describe $(gcloud config get-value project) --format="value(projectNumber)")
CLUSTER_NAME=$(terraform output -raw eks_name)

/google/src/cloud/zicong/proxy/google3/blaze-bin/cloud/sdk/gcloud/gcloud \
  container attached clusters register $CLUSTER_NAME \
  --location=us-west1 \
  --fleet-project=$PROJECT_NUMBER \
  --platform-version=1.27-next \
  --distribution=eks \
  --context=${KUBECTL_CONTEXT} \
  --issuer-url=$ISSUER_URL \
  --admin-users=$USER@google.com \
  --enable-managed-prometheus \
  --secret-name=proxy-config \
  --secret-namespace=default
