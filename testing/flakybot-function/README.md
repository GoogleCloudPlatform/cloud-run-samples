# Flakybot Function

This Cloud Function sends Cloud Build test results to [flakybot](https://github.com/googleapis/repo-automation-bots/tree/master/packages/flakybot) for failure processing.

## Architecture

Cloud Build publishes all build status changes to the `cloud-builds` Pub/Sub topic. This function subscribes to that topic and analyzes all messages associated with a final build status.

Those messages are converted into a junit_xml file which is sent to flakybot.

Flakybot then performs analysis such as flaky test detection and opens issues in the repo for test improvement.

## Deploy

To deploy the function:

- Authorize gcloud: `gcloud auth login`
- Set to the correct project: `gcloud config set project {project_id}`
- Ensure the functions API is enabled: `gcloud services enable cloudfunctions.googleapis.com`
- Run the deploy_function.sh script: `sh deploy_function.sh`
