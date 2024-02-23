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

export MC_SERVICE_NAME="${_SERVICE_NAME}-$BUILD_ID"

# Substituting the env vars in cloud run yaml file
sed -i -e s/MC_SERVICE_NAME/${MC_SERVICE_NAME}/g -e s/REGION/${_REGION}/g service.yaml

# Note that nginx_config secret has already been created within project.
# Deploy multi-container service "nginx-example" that includes nginx proxy.
gcloud run services replace service.yaml --region ${_REGION} --quiet

# Wait till deployment completes
sleep 10

# Retrieve multi-containter service url.
MC_URL=$(gcloud run services describe ${MC_SERVICE_NAME} --region ${_REGION} --format 'value(status.url)')

# Retrieve service deployment status.
MC_STATUS=$(gcloud run services describe ${MC_SERVICE_NAME} --region ${_REGION} --format 'value(status.conditions[0].type)')

if [[ -z "${MC_URL}"  && "${MC_STATUS}" != "Ready" ]]
then
  echo "No Cloud Run MC url found. Step e2e-test failed."
  exit 1
fi

# Check Cloud Run MC logs for signs of successful request to hello container.
MC_HELLO_LOG=$(gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=${MC_SERVICE_NAME} AND labels.container_name=hello" --limit 2 | grep -e 'Hello from Cloud Run')

if [[ -z "${MC_HELLO_LOG}" ]]
then
  echo "No Cloud Run MC success hello logs found. Step e2e-test failed."
  exit 1
else
  echo "Cloud Run MC successully deployed and nginx successfully proxied request."
  exit 0
fi
