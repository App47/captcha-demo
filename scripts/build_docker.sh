set -euox pipefail

ACCOUNT_ID="883585999409"
REGION="us-east-1"
REPO="app47/captcha-demo"
ECR="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
TAG="latest"
IMAGE="${ECR}/${REPO}:${TAG}"

#aws ecr get-login-password --region "${REGION}" | docker login --username AWS --password-stdin "${ECR}"

# Ensure buildx is available and use amd64 for ECS
docker buildx create --use >/dev/null 2>&1 || true

docker buildx build \
  --platform linux/amd64 \
  -t "${IMAGE}" \
  --push .

# Optionally keep/update a 'latest' pointer
# docker buildx imagetools create -t "${ECR}/${REPO}:latest" "${IMAGE}"

# Roll the service
aws ecs update-service \
  --cluster captcha-demo-cluster \
  --service captcha-demo-service \
  --force-new-deployment \
  --region "${REGION}"
