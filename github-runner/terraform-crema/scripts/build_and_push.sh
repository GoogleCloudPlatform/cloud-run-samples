#!/usr/bin/env bash
# Copyright 2026 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_DIR="$(cd "${SCRIPT_DIR}/../docker" && pwd)"

PROJECT_ID="${PROJECT_ID:-}"
REGION="${REGION:-us-central1}"
REPO_NAME="${REPO_NAME:-github-runner-repo}"
IMAGE_NAME="${IMAGE_NAME:-github-actions-runner}"
TAG="${TAG:-latest}"
WORKER_POOL_NAME="${WORKER_POOL_NAME:-github-runner-pool}"

if [[ -z "$PROJECT_ID" ]]; then
  echo "[-] ERROR: PROJECT_ID environment variable must be set."
  echo "    Usage: PROJECT_ID=my-project REGION=us-central1 ./scripts/build_and_push.sh"
  exit 1
fi

IMAGE_URI="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME}:${TAG}"

echo "=================================================================="
echo " Building and Pushing GitHub Runner Image via Cloud Build"
echo " Target: ${IMAGE_URI}"
echo "=================================================================="

echo "[1/3] Ensuring Artifact Registry repository '${REPO_NAME}' exists in ${REGION}..."
gcloud artifacts repositories describe "$REPO_NAME" \
  --project="$PROJECT_ID" \
  --location="$REGION" >/dev/null 2>&1 || \
gcloud artifacts repositories create "$REPO_NAME" \
  --project="$PROJECT_ID" \
  --location="$REGION" \
  --repository-format=docker \
  --description="Docker repository for Cloud Run GitHub Actions runners"

echo "[2/3] Submitting build to Google Cloud Build in ${REGION}..."
gcloud builds submit "$DOCKER_DIR" \
  --project="$PROJECT_ID" \
  --region="$REGION" \
  --default-buckets-behavior=regional-user-owned-bucket \
  --tag="$IMAGE_URI"

echo "==> Successfully built and pushed runner image: ${IMAGE_URI}"

if gcloud beta run worker-pools describe "$WORKER_POOL_NAME" \
  --project="$PROJECT_ID" \
  --region="$REGION" >/dev/null 2>&1; then
  IMAGE_DIGEST=$(gcloud artifacts docker images describe "$IMAGE_URI" \
    --project="$PROJECT_ID" \
    --format="value(image_summary.digest)" 2>/dev/null || true)
  TARGET_IMAGE="${IMAGE_URI}"
  if [[ -n "$IMAGE_DIGEST" ]]; then
    TARGET_IMAGE="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME}@${IMAGE_DIGEST}"
  fi
  echo "[3/3] Updating Cloud Run Worker Pool '${WORKER_POOL_NAME}' to new image (${TARGET_IMAGE})..."
  gcloud beta run worker-pools update "$WORKER_POOL_NAME" \
    --project="$PROJECT_ID" \
    --region="$REGION" \
    --image="$TARGET_IMAGE"
  echo "==> Worker Pool '${WORKER_POOL_NAME}' updated to latest revision."
else
  echo "[3/3] Worker Pool '${WORKER_POOL_NAME}' does not exist yet; skipping update (will be created by Terraform)."
fi
