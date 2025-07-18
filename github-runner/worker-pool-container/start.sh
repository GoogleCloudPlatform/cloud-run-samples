#!/bin/bash

set -e

# Prepare internal variables.
GITHUB_REPO_URL=https://github.com/${GITHUB_REPO}
GH_TOKEN=$GITHUB_RUNNER_TOKEN

RUNNER_PREFIX="cloud-run-worker"
RUNNER_SUFFIX=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 5 | head -n 1)
RUNNER_NAME="${RUNNER_PREFIX}-${RUNNER_SUFFIX}"

# [START run_github_worker_pool_start]
# Configure the current runner instance with URL, token and name.
mkdir /home/docker/actions-runner && cd /home/docker/actions-runner
echo ${GITHUB_REPO_URL}
./config.sh --unattended --url ${GITHUB_REPO_URL} --token ${GH_TOKEN} --name ${RUNNER_NAME}

# Function to cleanup and remove runner from Github.
cleanup() {
   echo "Removing runner..."
./config.sh remove --unattended --token ${GH_TOKEN}
}

# Trap signals.
trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

# Run the runner.
./run.sh & wait $!

# [END run_github_worker_pool_start]
