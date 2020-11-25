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
# local-runner.sh
# Passthrough executor that ensures gcloud is properly authenticated and configured for use.
# 
# Usage:
# /bin/bash local-runner.sh script.sh
##
set -eo pipefail

requireEnv() {
  test "${!1}" || (echo "local-runner: '$1' not found" >&2 && exit 1)
}

requireEnv GOOGLE_CLOUD_PROJECT
requireEnv GOOGLE_APPLICATION_CREDENTIALS

gcloud auth activate-service-account --key-file "${GOOGLE_APPLICATION_CREDENTIALS}"

export CLOUDSDK_CORE_PROJECT="${GOOGLE_CLOUD_PROJECT}"

"$@"
