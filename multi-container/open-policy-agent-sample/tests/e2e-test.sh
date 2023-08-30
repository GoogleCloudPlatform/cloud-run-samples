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

export SERVICE_NAME="${_SERVICE_NAME}-$BUILD_ID"

# Substituting the env vars in cloud run yaml file
sed -i -e s/SERVICE_NAME/${SERVICE_NAME}/g -e s/REGION/${_REGION}/g -e s/\<PROJECT_ID\>/${PROJECT_ID}/g -e s/\<IMAGE_NAME\>/${IMAGE_NAME}/g opa-service.yaml

# Note that nginx_config secret has already been created within project.
# Deploy multi-container service "nginx-example" that includes nginx proxy.
gcloud run services replace opa-service.yaml --region ${_REGION} --quiet

# Wait till deployment completes
sleep 10

# Retrieve multi-containter service url.
URL=$(gcloud run services describe ${SERVICE_NAME} --region ${_REGION} --format 'value(status.url)')

# Retrieve service deployment status.
STATUS=$(gcloud run services describe ${SERVICE_NAME} --region ${_REGION} --format 'value(status.conditions[0].type)')

if [[ -z "${URL}"  && "${STATUS}" != "Ready" ]]
then
  echo "No Cloud Run opa sample url found. Step e2e-test failed."
  exit 1
fi

# check that it's responding at all
RESULT=`curl ${URL}`

if [[ $RESULT != *"Your client does not have permission to get URL"* ]]; then
  echo "No Cloud Run opa sample found deployed. Step e2e-test failed."
  exit 1
fi


RESULT=`curl --user alice:password ${URL}/finance/salary/alice`
echo $RESULT
if [[ $RESULT != *"Error: user Anonymous is not authorized to GET url /"* ]]; then
  echo "opa not functioning properly. Step e2e-test failed."
  exit 1
fi

echo "Cloud Run opa sample successully deployed and nginx successfully proxied request."
exit 0