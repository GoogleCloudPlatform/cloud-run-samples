#!/usr/bin/env bash
set -eo pipefail

requireEnv() {
  test "${!1}" || (echo "local-runner: '$1' not found" >&2 && exit 1)
}

requireEnv GOOGLE_CLOUD_PROJECT
requireEnv GOOGLE_APPLICATION_CREDENTIALS

gcloud auth activate-service-account --key-file "${GOOGLE_APPLICATION_CREDENTIALS}"

export CLOUDSDK_CORE_PROJECT="${GOOGLE_CLOUD_PROJECT}"

"$@"
