This function subscribes to the cloud-builds topic.  It parses the Cloud Build messages and compiles a junit_xml file, and sends the results to the [flakybot](https://github.com/googleapis/repo-automation-bots/tree/master/packages/flakybot).

To deploy the function:

- Authorize gcloud: `gcloud auth login`
- Set to the correct project: `gcloud config set project {project_id}`
- Ensure the functions API is enabled: `gcloud services enable cloudfunctions.googleapis.com`
- Run the deploy_function.sh script: `sh deploy_function.sh`
