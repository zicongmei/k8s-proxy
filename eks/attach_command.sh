#!/bin/bash

set -ex

# connect to the created EKS
$(terraform output -raw get_kubeconfig)

PROXY_URL=$(terraform output -raw proxy_config)
PROXY_ENCODED=$(echo ${PROXY_URL}| base64 -w 0)
VPC_CIDR_RANGE=$(terraform output -raw cidr)
AWS_REGION=$(terraform output -raw region)
NO_PROXY="172.20.0.0/16,localhost,127.0.0.1,${VPC_CIDR_RANGE},169.254.169.254,.internal,s3.amazonaws.com,.s3.${AWS_REGION}.amazonaws.com,api.ecr.${AWS_REGION}.amazonaws.com,dkr.ecr.${AWS_REGION}.amazonaws.com,ec2.${AWS_REGION}.amazonaws.com"
NO_PROXY_ENCODED=$(echo -n $NO_PROXY | base64 -w 0)


KUBECTL_CONTEXT=$(kubectl config current-context)
ISSUER_URL=$(terraform output -raw get_issuerURL)
PROJECT_NUMBER=$(gcloud projects describe $(gcloud config get-value project) --format="value(projectNumber)")
CLUSTER_NAME=$(terraform output -raw eks_name)

cat << EOF >  /tmp/proxy-config-eks.yaml
apiVersion: v1
kind: Secret
metadata:
  name: proxy-config
  namespace: default
type: Opaque
immutable: true
data:
  httpProxy: $PROXY_ENCODED
  httpsProxy: $PROXY_ENCODED
  noProxy: $NO_PROXY_ENCODED
---
# resuired by EKS. https://repost.aws/knowledge-center/eks-http-proxy-configuration-automation
apiVersion: v1
kind: ConfigMap
metadata:
 name: proxy-environment-variables
 namespace: kube-system
data:
 HTTP_PROXY: $PROXY_URL
 HTTPS_PROXY: $PROXY_URL
 NO_PROXY: $NO_PROXY
EOF

kubectl apply -f /tmp/proxy-config-eks.yaml

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
