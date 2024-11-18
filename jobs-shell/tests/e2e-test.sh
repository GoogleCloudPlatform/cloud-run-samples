#!/bin/bash
# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -eux pipefail

SHORT_SHA="${SHORT_SHA:-latest}"

gcloud config set run/region "${_REGION}"

JOB_NAME="jobs-shell-${BUILD_ID}"
AR_REPO_NAME=${_AR_REPO_REGION}-docker.pkg.dev/${PROJECT_ID}/${_AR_REPO_NAME}/jobs-shell

gcloud builds submit -t "${AR_REPO_NAME}:${SHORT_SHA}"

gcloud run jobs create "${JOB_NAME}" \
  --set-env-vars FAIL_RATE=0,SLEEP_MS=10 \
  --max-retries 2 \
  --tasks 5 \
  --image "${AR_REPO_NAME}/jobs-shell:${SHORT_SHA}"

# Because of --wait, the command will fail if the
# execution fails, causing the entire script to fail
gcloud run jobs execute "${JOB_NAME}" \
  --format=json \
  --wait
