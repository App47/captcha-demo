#!/usr/bin/env bash
set -euo pipefail

: "${AWS_REGION:?AWS_REGION is required}"
: "${AWS_ACCOUNT_ID:?AWS_ACCOUNT_ID is required}"
: "${ECR_REPOSITORY:?ECR_REPOSITORY is required}"
: "${RELEASE_TAG:?RELEASE_TAG is required}"

REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

# Inputs (optional)
SOURCE_TAG="${SOURCE_TAG:-latest}"
SHA_DIGEST="${SHA_DIGEST:-}"

# Build the image-ids selector
if [[ -n "$SHA_DIGEST" ]]; then
  SELECTOR="imageDigest=${SHA_DIGEST}"
  echo "Promoting by digest: ${SHA_DIGEST}"
else
  SELECTOR="imageTag=${SOURCE_TAG}"
  echo "Promoting by tag: ${SOURCE_TAG}"
fi

MANIFEST=$(aws ecr batch-get-image \
  --repository-name "${ECR_REPOSITORY}" \
  --image-ids "${SELECTOR}" \
  --accepted-media-types application/vnd.docker.distribution.manifest.v2+json \
                          application/vnd.docker.distribution.manifest.list.v2+json \
  --query 'images[0].imageManifest' \
  --output text)

if [[ -z "${MANIFEST}" || "${MANIFEST}" == "None" ]]; then
  echo "ERROR: Could not fetch manifest for ${SELECTOR} in ${ECR_REPOSITORY}" >&2
  exit 1
fi

aws ecr put-image \
  --repository-name "${ECR_REPOSITORY}" \
  --image-tag "${RELEASE_TAG}" \
  --image-manifest "${MANIFEST}"

echo "Tagged ${REGISTRY}/${ECR_REPOSITORY}:${RELEASE_TAG}"