# Testing for Cloud Run Samples

A Google Cloud Project is required in order to run the tests in the Cloud Run Samples. The project should have the following API's enabled:

* Cloud Run
* Cloud Build
* Pub/Sub
* Container Registry
* Secret Manager

## Test Project Setup

The [test-project-setup.sh](./test-project-setup.sh) script will set up a project with the appropriate permissions to run the tests. To run the script you will need to set the following environment variables locally:

* TEAM_FOLDER [optional]
  * The numeric ID of the [folder][folder]
  * Note: TEAM_FOLDER is optional for the script, but may be required by your organization policy.

* PROJECT_SUFFIX [required]
  * Number to be attached at the end of the PROJECT_ID in order to create a unique project id.
  * Eg: 2

Once basic project setup is in place, Cloud Build must be given access to deploy Cloud Run services (see [Deploying to Cloud Run][access]).

Lastly, the Cloud Build GitHub App needs to be installed and connected to the repository. More info can be found in [Installing the Cloud Build app][app].

### Billing

The script checks your current active project to obtain the Billing Account, in order to enable the API's. This account is then linked to the new testing project.

If your current project does not have a billing account enabled, it will force the program to exit. To select a project to use for your billing account, run `gcloud config set project {PROJECT_ID}`.

## Cloud Build Templates

Cloud Build templates for Cloud Run E2E testing can be found in the
`cloudbuild-templates/` directory.

* [User-defined substitutions][sub], such as `_SAMPLE` and `_SERVICE`.

* Add integration tests, see examples below:

  * Using a shell script:

    ```yaml
    - id: 'Integration Tests'
      name: 'gcr.io/cloud-builders/curl'
      entrypoint: '/bin/sh'
      dir: $_SAMPLE
      args:
      - '-c'
      - |
        SERVICE_URL=$(cat _service_url) sh integration-tests.sh
    ```

  * Language specific testing:

    ```yaml
    - id: 'Integration Tests'
      name: 'maven:3-openjdk-11'
      entrypoint: '/bin/bash'
      dir: $_SAMPLE
      args:
      - '-c'
      - |
        SERVICE_URL=$(cat _service_url) mvn verify
    ```

**Note:** The build steps for getting the Cloud Run URL and IP are used to
export environment variables into the test runner.

### Testing private services in Cloud Run (fully managed)

Cloud Run services are deployed privately as a best practice: humans choose to make a service public, not the CI system. Cloud Run is deployed with the `--no-allow-unauthenticated` flag
to keep it private. To send HTTPS requests to the Cloud Run service, an identity token is required for [an account with the Cloud Run invoker permission](https://cloud.google.com/run/docs/authenticating/service-to-service).

To mint identity tokens on Cloud Build, load an alternate service identity with this permision in the 'Get Cloud Run URL' build step:

```sh
gcloud secrets versions access latest --secret ${_SECRET_NAME} > _sa_key.json
account=$(gcloud config get-value account)
gcloud auth activate-service-account ${_RUNNER_IDENTITY} \
  --key-file _sa_key.json --project ${PROJECT_ID}
gcloud auth print-identity-token --audiences "$(cat _service_url)" > _id_token
gcloud config set account ${account}
rm _sa_key.json
```

This secret is populated by a separate key rotation process, such as:

```sh
export SERVICE_ACCOUNT="test-runner-identity"
gcloud iam services-accounts keys create "${SERVICE_ACCOUNT}-key.json" \
  --iam-account "${SERVICE_ACCOUNT}@${TESTING_PROJECT}.iam.gserviceaccount.com"
gcloud secrets versions add ${SECRET_NAME} --data-file "${SERVICE_ACCOUNT}-key.json"
rm $SERVICE_ACCOUNT-key.json
```

Once done, any previous key should be revoked.

## Cloud Build Triggers

Each sample with tests requires two Cloud Build triggers:

* A **Pull Request trigger** which checks incoming changes.
* A **Nightly trigger** which checks the affects of product changes, environment changes, and flakiness.

These triggers are created using trigger configuration files.

1. Create the sample Pull Request trigger config (`pr.trigger-config.yaml`):

   ```yaml
   name: SAMPLE-pr
   description: pull-request
   github:
     name: cloud-run-samples
     owner: GoogleCloudPlatform
     pullRequest:
       branch: ^main$
       commentControl: COMMENTS_ENABLED_FOR_EXTERNAL_CONTRIBUTORS_ONLY
   includedFiles:
   - SAMPLE_DIR/**
   filename: SAMPLE_DIR/cloudbuild.yaml
   ```

1. Create the sample Nightly trigger config (`nightly.trigger-config.yaml`):

   Our nightly testing uses "manual" Cloud Build triggers. The Cloud Build Trigger UI is currently the only way to create manual triggers. A current work around is creating a "Push to branch" event trigger. This can be manually triggered and can be updated via the UI to be a "Manually run" trigger.

   ```yaml
   name: SAMPLE-nightly
   description: nightly
   github:
     name: cloud-run-samples
     owner: GoogleCloudPlatform
     push: # TODO: Update when manual triggers are supported
       branch: nightly
   includedFiles:
   - SAMPLE_DIR/**
   filename: SAMPLE_DIR/cloudbuild.yaml
   ```

1. Create a Cloud Build trigger using a config file:

   ```sh
   gcloud beta builds triggers create github \
     --trigger-config=sample/path/pr.trigger-config.yaml
   gcloud beta builds triggers create github \
     --trigger-config=sample/path/nightly.trigger-config.yaml
   ```

## Manually Start Cloud Builds

To manually trigger a Cloud Run (fully managed) build via CLI:

```sh
$SAMPLE=sample-name
gcloud builds submit \
  --config "$SAMPLE/tests.cloudbuild.yaml" \
  --substitutions "SHORT_SHA=manual,_SAMPLE_DIR=${SAMPLE},_SECRET_NAME=${SECRET_NAME},_RUNNER_IDENTITY=${SERVICE_ACCOUNT}@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com"
```

We run from base directory of the repository for access to the common.sh script.

To manually trigger a Cloud Run for Anthos build via CLI:

```sh
cd $SAMPLE
gcloud builds submit --substitutions 'SHORT_SHA=manual,_SAMPLE_DIR=.'
```

[folder]: https://cloud.google.com/sdk/gcloud/reference/projects/create#--folder
[access]: https://cloud.google.com/cloud-build/docs/deploying-builds/deploy-cloud-run
[app]: https://cloud.google.com/cloud-build/docs/automating-builds/create-github-app-triggers#installing_the_cloud_build_app
[sub]: https://cloud.google.com/cloud-build/docs/configuring-builds/substitute-variable-values#using_user-defined_substitutions
