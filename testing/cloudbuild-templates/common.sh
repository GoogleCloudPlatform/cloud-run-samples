#!/usr/bin/env bash
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

##
# common.sh
# Provides utility functions commonly needed across Cloud Build pipelines.
#
# This is expected to be used from cloud-run-template.cloudbuild.yaml and 
# should be "forked" into an individual sample that does not provide the same
# environment variables and workspace.
#
# It is kept separate for two reasons:
# 1. Simplicity of cloudbuild.yaml files.
# 2. Easier evaluation of security implications in changes to get_idtoken().
#
# Usage
# If you do not need to fork this script, directly source it in your YAML file:
#
# ```
# . /testing/cloudbuild-templates/common.sh
# echo $(get_url) > _service_url
# ```
##

# Cloud Run URLs are not deterministic.
get_url() {
    bid=$(test "$1" && echo "$1" || cat _short_id)

    gcloud run services describe ${_SERVICE}-${bid} \
        --format 'value(status.url)'
}

# Cloud Build does not natively mint identity tokens.
# A separate mechanism pushes a Service Account key into Secret Manager
# which can be used to create identity tokens.
get_idtoken() {
    set -x
    gcloud secrets versions access latest --secret ${_SECRET_NAME} > _sa_key.json
    # Capture the current authenticated account.
    account=$(gcloud config get-value account)
    gcloud auth activate-service-account ${_RUNNER_IDENTITY} --key-file _sa_key.json --project ${GOOGLE_CLOUD_PROJECT}
    gcloud auth print-identity-token --audiences "$(cat _service_url)"
    # Switch to the original account.
    gcloud config set account ${account}
    set +x
    rm _sa_key.json
} 
