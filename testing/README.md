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
`cloudbuild-templates/` directory. The `TODO` comment highlights areas that will
need to be updated:

* [User-defined substitutions][sub], such as `_SAMPLE` and `_SERVICE`.

* Evaluate the `--allow-unauthenticated` flag.

* Add integration tests, see examples below:

  * Using a shell script:
    ```
    - id: 'Integration Tests'
      name: 'alpine:3'
      entrypoint: '/bin/sh'
      dir: $_SAMPLE
      args:
      - '-c'
      - |
        SERVICE_URL=$(cat _service_url) sh integration-tests.sh
    ```

  * Language specific testing:
    ```
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

## Cloud Build Triggers

Before trigger creation, you need to enable access for the Cloud Build service account to deploy the service. More information can be found in [Setting up continuous deployment with Cloud Build][access]. The Cloud Build GitHub App also needs to be installed and connected to the repository. More info can be found in [Installing the Cloud Build app][app].

Add a Cloud Build trigger config YAML file:
```YAML
name: SAMPLE-pr
description: pull-request
github:
  name: cloud-run-samples
  owner: GoogleCloudPlatform
  pullRequest:
    branch: ^master$
includedFiles:
- SAMPLE_DIR/**
filename: SAMPLE_DIR/cloudbuild.yaml
```

Create the Cloud Build trigger:
```shell
gcloud beta builds triggers create github --trigger-config=path/to/trigger-config.yaml
```

**Note:** The Cloud Build Trigger UI is currently the only way to create manual
triggers.

## Manually Start Cloud Build

To manually trigger a Cloud Build from your CLI:
```
cd $SAMPLE
gcloud builds submit --substitutions '_SAMPLE_DIR=.,SHORT_SHA=manual'
```

[access]: https://cloud.google.com/run/docs/continuous-deployment-with-cloud-build#continuous
[app]: https://cloud.google.com/cloud-build/docs/automating-builds/create-github-app-triggers#installing_the_cloud_build_app
[sub]: https://cloud.google.com/cloud-build/docs/configuring-builds/substitute-variable-values#using_user-defined_substitutions
