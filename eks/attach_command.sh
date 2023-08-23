

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
