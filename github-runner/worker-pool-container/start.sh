#!/bin/bash
# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


set -e

# Prepare internal variables.
GITHUB_REPO_URL=https://github.com/${GITHUB_REPO}
GH_TOKEN=$GITHUB_TOKEN

RUNNER_PREFIX="cloud-run-worker"
RUNNER_SUFFIX=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 5 | head -n 1)
RUNNER_NAME="${RUNNER_PREFIX}-${RUNNER_SUFFIX}"

# [START run_github_worker_pool_start]
# Configure the current runner instance with URL, token and name.
mkdir /home/docker/actions-runner && cd /home/docker/actions-runner
echo "🆕 GitHub Repo: ${GITHUB_REPO_URL} for ${RUNNER_PREFIX}-${RUNNER_SUFFIX}"
./config.sh  --unattended --ephemeral --url ${GITHUB_REPO_URL} --pat ${GH_TOKEN} --name ${RUNNER_NAME}

# Function to cleanup and remove runner from Github.
cleanup() {
   echo "🧹 Removing runner..."
   ./config.sh  remove --unattended --ephemeral --pat ${GH_TOKEN}
}

# Trap signals.
trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

# Run the runner.
./run.sh & wait $!

# [END run_github_worker_pool_start]
