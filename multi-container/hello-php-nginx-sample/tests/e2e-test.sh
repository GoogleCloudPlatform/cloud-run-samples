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

export MC_SERVICE_NAME="${SERVICE_NAME}-$BUILD_ID"

# Substituting the env vars in cloud run yaml file
sed -i -e s/MC_SERVICE_NAME/${MC_SERVICE_NAME}/g -e s/REGION/${REGION}/g -e s/REPO_NAME/${REPO_NAME}/g -e s/PROJECT_ID/${PROJECT_ID}/g service.yaml

# Note that nginx_config secret has already been created within project.
gcloud run services replace service.yaml --region ${REGION} --quiet

# Wait till deployment completes
sleep 10

# Retrieve multi-containter service url.
MC_URL=$(gcloud run services describe ${MC_SERVICE_NAME} --region ${REGION} --format 'value(status.url)')

# Retrieve service deployment status.
MC_STATUS=$(gcloud run services describe ${MC_SERVICE_NAME} --region ${REGION} --format 'value(status.conditions[0].type)')

if [[ -z "${MC_URL}"  && "${MC_STATUS}" != "Ready" ]]
then
  echo "No Cloud Run MC url found. Step e2e-test failed."
  exit 1
fi

# Checking that fpm (FastCGI Process Manager)
MC_NGINX_LOG=$(gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=${MC_SERVICE_NAME} AND labels.container_name=nginx" | grep -e 'Default STARTUP TCP probe succeeded after 1 attempt for container "nginx"')

# Check Cloud Run MC nginx & hellophp logs for signs of successful deployment and connection
MC_HELLO_PHP_LOG=$(gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=${MC_SERVICE_NAME} AND labels.container_name=hellophp" | grep -e 'NOTICE: fpm is running, pid 1')

if [[ -z "${MC_HELLO_PHP_LOG}" && -z "${MC_NGINX_LOG}" ]]
then
  echo "No Cloud Run MC success hellophp or nginx logs found. Step e2e-test failed."
  exit 1
else
  echo "Cloud Run MC successully deployed and nginx successfully proxied php app with FastCGI."
  exit 0
fi