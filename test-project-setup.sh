#!/bin/bash
# Copyright 2020 Google LLC
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


setup () {
  # TEAM FOLDER must be in set in local environment
  if [[ ! ${TEAM_FOLDER} ]]
  then exit
  fi

  export PARENT_PROJECT=$(gcloud config get-value project)
  # PARENT PROJECT required for getting billing account
  if [[ ! ${PARENT_PROJECT} ]]
  then exit
  fi

  export BILLING_ACCOUNT=$(gcloud beta billing projects describe ${PARENT_PROJECT} --format="value(billingAccountName)" || sed -e 's/.*\///g')
  # BILLING ACCOUNT required for API enablement
  if [[ ! ${BILLING_ACCOUNT} ]]
  then exit
  fi

  export TESTING_PROJECT=$(printf "cloud-run-samples-test-%06d" $((RANDOM%999999)))
  export PROJECT_REGION=us-central1

  echo "Setting up project for Cloud Run Samples Testing..."; set -x
  gcloud projects create ${TESTING_PROJECT} --folder=${TEAM_FOLDER}
  gcloud beta billing projects link ${TESTING_PROJECT} --billing-account=${BILLING_ACCOUNT}
  gcloud config set project ${TESTING_PROJECT}
  set +x; echo

  echo "Enabling apis..."; set -x
  gcloud services enable compute.googleapis.com
  gcloud services enable run.googleapis.com
  gcloud services enable cloudbuild.googleapis.com
  gcloud services enable pubsub.googleapis.com
  gcloud services enable containerregistry.googleapis.com
  set +x; echo
}

setup