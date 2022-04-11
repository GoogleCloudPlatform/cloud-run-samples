#!/bin/bash
set -eux pipefail

# Remove me
PROJECT_ID=$(gcloud config get project)

gcloud config set run/region "${_REGION}"

# Generate a random 15 character alphanumeric string (lowercase only)
RAND_ID=$(LC_CTYPE=C tr -dc 'a-z0-9' < /dev/urandom | head -c 15)
JOB_NAME="jobs-shell-${RAND_ID}"

gcloud builds submit -t "gcr.io/${PROJECT_ID}/jobs-shell"

gcloud alpha run jobs create "${JOB_NAME}" \
  --set-env-vars FAIL_RATE=0.1,SLEEP_MS=100 \
  --max-retries 10 \
  --tasks 5 \
  --image "gcr.io/${PROJECT_ID}/jobs-shell"

# Because of --wait, the command will fail if the 
# execution fails, causing the entire script to fail
gcloud alpha run jobs execute "${JOB_NAME}" \
  --format=json \
  --wait 

gcloud alpha run jobs delete --quiet "${JOB_NAME}"