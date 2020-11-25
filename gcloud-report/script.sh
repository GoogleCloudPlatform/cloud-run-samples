#!/usr/bin/env bash
# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

##
# script.sh
# Uses gcloud to create a report of Cloud Run services.
# Uses gsutil to write the report to Cloud Storage.
#
# Requires GCLOUD_REPORT_BUCKET environment variable
##

# [START cloudrun_report_script]
set -eo pipefail

# Check for required environment variables.
requireEnv() {
  test "${!1}" || (echo "gcloud-report: '$1' not found" >&2 && exit 1)
}
requireEnv GCLOUD_REPORT_BUCKET

# Prepare formatting: Default search term to include all services.
search=${1:-'.'}
limits='spec.template.spec.containers.resources.limits.flatten("", "", " ")'
format='table[box, title="Cloud Run Services"](name,status.url,metadata.annotations.[serving.knative.dev/creator],'${limits}')'

# Create a specific object name that will not be overridden in the future.
obj="gs://${GCLOUD_REPORT_BUCKET}/report-${search}-$(date +%s).txt"

# Write a report containing the service name, service URL, service account or user that
# deployed it, and any explicitly configured service "limits" such as CPU or Memory.
gcloud run services list \
  --platform managed \
  --format "${format}" \
  --filter "metadata.name~${search}" | gsutil -q cp -J - "${obj}"

# /dev/stderr is sent to Cloud Logging.
echo "gcloud-report: wrote to ${obj}" >&2
echo "Wrote report to ${obj}"

# [END cloudrun_report_script]
