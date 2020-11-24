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

set -e

setup () {
  # TEAM FOLDER is an optional variable to be in set in local environment
  if [[ ! ${TEAM_FOLDER} ]]
  then echo "WARNING: You are creating this project without a Team Folder.\n\n\
If you are creating this project in an organization, there may be \
a policy on project folders and project creation may fail. To move the project \
after completion see \
https://cloud.google.com/resource-manager/docs/migrating-projects-billing";
  fi

  # PROJECT SUFFIX must be in set in local environment
  if [[ ! ${PROJECT_SUFFIX} ]]
  then echo "PROJECT_SUFFIX must be set in local environment."; exit
  fi
  export TESTING_PROJECT=cloud-run-samples-test-${PROJECT_SUFFIX}

  # BILLING ACCOUNT required for API enablement
  export BILLING_ACCOUNT=$(gcloud beta billing projects describe $(gcloud config get-value project) --format="value(billingAccountName)" || sed -e 's/.*\///g')
  if [[ ! ${BILLING_ACCOUNT} ]]
  then echo "BILLING_ACCOUNT missing. \
            Please select an active project with a billing account, by running \
            gcloud config set project {PROJECT_ID}"; exit
  fi

  echo "Setting up project for Cloud Run Samples Testing..."
  if [[ ${TEAM_FOLDER} ]]; set -x
  then gcloud projects create ${TESTING_PROJECT} --folder=${TEAM_FOLDER}
  else gcloud projects create ${TESTING_PROJECT}
  fi

  gcloud beta billing projects link ${TESTING_PROJECT} --billing-account=${BILLING_ACCOUNT}

  echo "Enabling apis..."
  gcloud services enable run.googleapis.com --project $TESTING_PROJECT
  gcloud services enable cloudbuild.googleapis.com --project $TESTING_PROJECT
  gcloud services enable pubsub.googleapis.com --project $TESTING_PROJECT
  gcloud services enable containerregistry.googleapis.com --project $TESTING_PROJECT
  gcloud services enable secretmanager.googleapis.com --project $TESTING_PROJECT
  gcloud services enable vpcaccess.googleapis.com --project $TESTING_PROJECT

  if [[ ${IAM_OWNER} ]]
  then 
  echo "Giving project permission to owner..."
  gcloud projects add-iam-policy-binding ${TESTING_PROJECT} \
    --member="${IAM_OWNER}" --role="roles/owner"
  gcloud projects add-iam-policy-binding ${TESTING_PROJECT} \
    --member="${IAM_OWNER}" --role="roles/resourcemanager.projectIamAdmin"
  fi
  
  echo "Creating VPC Serverless Connector..."
  gcloud compute networks vpc-access connectors create samples-connector \
  --region=us-central1 --range=10.8.0.0/28


  echo "Setting up Cloud Run invoker access..."
  gcloud iam service-accounts create test-runner-identity
  RUNNER_EMAIL="test-runner-identity@${TESTING_PROJECT}.iam.gserviceaccount.com"

  gcloud projects add-iam-policy-binding "${TESTING_PROJECT}" \
    --member "serviceAccount:${RUNNER_EMAIL}" \
    --role roles/run.invoker

  gcloud secrets create locksmith-secret \
    --replication-policy "automatic"

  PROJECT_NUMBER=$(gcloud projects describe $TESTING_PROJECT --format 'value(projectNumber)')
  gcloud secrets add-iam-policy-binding locksmith-secret \
    --member "serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
    --role roles/secretmanager.secretAccessor

  echo "Creating Cloud Storage bucket for sample integration"
  gsutil mb gs://${TESTING_PROJECT}
  // Delete objects in this bucket after 3 days.
  gsutil lifecycle set sample-storage.lifecycle.json gs://${TESTING_PROJECT}

  echo "Project setup complete"
}

setup
