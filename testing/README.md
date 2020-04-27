# Testing for Cloud Run Samples

A Google Cloud Project is required in order to run the tests in the Cloud Run Samples. The project should have the following API's enabled:

* Cloud Run
* Cloud Build
* Pub/Sub
* Container Registry

## Test Project Setup

The [test-project-setup.sh](./test-project-setup.sh) script will set up a project with the appropriate permissions to run the tests.  To run the script you will need to set the following environment variables locally:

* TEAM_FOLDER [optional]
  * The numeric ID of the [folder](https://cloud.google.com/sdk/gcloud/reference/projects/create#--folder)
  * Note: TEAM_FOLDER is optional for the script, but may be required by your organization policy.

* PROJECT_SUFFIX [required]
  * Number to be attached at the end of the PROJECT_ID in order to create a unique project id.
  * Eg: 2

### Billing

The script checks your current active project to obtain the Billing Account, in order to enable the API's.  This account is then linked to the new testing project.

If your current project does not have a billing account enabled, it will force the program to exit. To select a project to use for your billing account, run ` gcloud config set project {PROJECT_ID}`

## Cloud Build Templates

Cloud Build templates for Cloud Run E2E testing can be found in the
`cloudbuild-templates/` directory. [User-defined substitutions][sub],
`_SAMPLE` and `_SERVICE`, need to be updated per sample.

## Cloud Build Triggers

### Individual Sample Triggers

Add `$SAMPLE` as an env var:
```shell
export SAMPLE=SAMPLE_FOLDER_NAME
```

Create the Cloud Build trigger:
```shell
gcloud beta builds triggers create github \
--build-config=$SAMPLE/cloudbuild.yaml \
--repo-name=cloud-run-samples \
--repo-owner=GoogleCloudPlatform \
--pull-request-pattern="^master$"
--name=$SAMPLE \
--include-files=$SAMPLE/*
```

### Repo Trigger

Add `$TRIGGER_NAME` as an env var:
```shell
export TRIGGER_NAME=NAME
```

Create the Cloud Build trigger:
```shell
gcloud beta builds triggers create github \
--build-config=cloudbuild.yaml \
--repo-name=cloud-run-samples \
--repo-owner=GoogleCloudPlatform \
--pull-request-pattern="^master$"
--name=$TRIGGER_NAME
```

Example `cloudbuild.yaml`

```yaml
steps:
- id: 'Lint Dockerfile'
  name: 'hadolint/hadolint:latest-debian'
  entrypoint: '/bin/bash'
  args:
    - '-c'
    - |
      hadolint */Dockerfile
```


[sub]: https://cloud.google.com/cloud-build/docs/configuring-builds/substitute-variable-values#using_user-defined_substitutions
