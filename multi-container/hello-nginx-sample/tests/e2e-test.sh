#!/bin/bash
# Copyright 2023 Google LLC
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

gcloud config set run/region "${_REGION}"

# Note that nginx_config secret has already been created within project

# Deploy multi-container service "nginx-example" that includes nginx proxy
gcloud run services replace service.yaml --quiet

# Wait for service to deploy
sleep 10

# Retrieve multi-containter service url
MC_URL="$(gcloud run services describe ${_SERVICE_NAME} --region ${_REGION} --format 'value(status.url)')"

# Retrieve service deployment status
MC_STATUS="$(gcloud run services describe ${_SERVICE_NAME} --region ${_REGION} --format 'value(status.conditions[0].type)')"

if [[ -z "${MC_URL}"  && "${MC_STATUS}" != "Ready" ]]
then
  echo "No Cloud Run MC url found. Step e2e-test failed."
  exit 1
fi

# Check Cloud Run MC logs for signs of successful request to hello container
MC_HELLO_LOG="$(gcloud logging read 'resource.type=cloud_run_revision AND resource.labels.service_name=${_SERVICE_NAME} AND labels.container_name=hello' --limit 1 | grep -e 'Hello from Cloud Run')"

if [[ -z "${MC_HELLO_LOG}" ]]
then
  echo "No Cloud Run MC success hello logs found. Step e2e-test failed."
  exit 1
else
  echo "Cloud Run MC successully deployed and nginx successfully proxied request."
  exit 0
fi
