# Cloud Run jobs sample

## Build

* Set an environment variable with your Google Cloud Project ID:

```
export GOOGLE_CLOUD_PROJECT=<PROJECT_ID>
```

* Set environment variable for your Artifact Registry (example, 'containers' in us-central1):

```
export AR_REPO_NAME=us-central1-pkg.dev/${PROJECT_ID}/containers
```

* Use Cloud Build to build the container:

```sh
gcloud builds submit -t "${AR_REPO_NAME}/jobs-shell"
```

## Run locally

```sh
docker run --rm ${AR_REPO_NAME}/jobs-shell

# Add a 1 second delay and fail the job with 90% chance.
docker run --rm -e FAIL_RATE=0.9 -e SLEEP_MS=1000 ${AR_REPO_NAME}/jobs-shell
```

## Create a job
```
gcloud run jobs create jobs-shell \
  --set-env-vars FAIL_RATE=0.4,SLEEP_MS=5000 \
  --max-retries 10 \
  --tasks 5 \
  --image "${AR_REPO_NAME}/jobs-shell"
```

## Execute the job
```
gcloud run jobs execute jobs-shell --wait
```
