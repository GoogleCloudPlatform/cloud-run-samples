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

## Run the function locally

```sh
pip install -r requirements.txt
functions-framework-python --target send_to_flakybot --signature-type event
```

### Send a request to the function

```sh
data=$(echo '{"status": "SUCCESS", "substitutions": {"COMMIT_SHA": "abc123"}, "logUrl": " https://console.cloud.google.com/cloud-build/builds/36576030-14d5-4d5c-b4e4-222d2ed7bf97?project=0", "id": "36576030-14d5-4d5c-b4e4-222d2ed7bf97", "steps": [{"id": "my-step", "status": "SUCCESS", "timing": {"startTime": "2021-03-19T18:51:45.604064649Z", "endTime": "2021-03-19T18:52:00.775895537Z"}}], "results": {"buildStepOutputs": ["example-output"]}}' | base64  -i -)

curl localhost:8080 \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
        "context": {
          "eventId":"1144231683168617",
          "timestamp":"2021-05-06T07:33:34.556Z",
          "eventType":"google.pubsub.topic.publish",
          "resource":{
            "service":"pubsub.googleapis.com",
            "name":"projects/example-project/topics/example-topic",
            "type":"type.googleapis.com/google.pubsub.v1.PubsubMessage"
          }
        },
        "data": {
          "@type": "type.googleapis.com/google.pubsub.v1.PubsubMessage",
          "attributes": {
             "attr1":"attr1-value"
          },
          "data": "'$data'"
        }
      }'
```
