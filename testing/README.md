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

## Billing

The script checks your current active project to obtain the Billing Account, in order to enable the API's.  This account is then linked to the new testing project.

If your current project does not have a billing account enabled, it will force the program to exit. To select a project to use for your billing account, run ` gcloud config set project {PROJECT_ID}`


