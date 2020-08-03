#!/usr/bin/env bash
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
    gcloud run services describe ${_SERVICE}-$(cat _short_id) \
        --format 'value(status.url)' \
        --platform managed
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