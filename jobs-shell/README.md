# Cloud Run jobs sample

## Build

* Set an environment variable with your GCP Project ID:

```
export GOOGLE_CLOUD_PROJECT=<PROJECT_ID>
```

* Use Cloud Build to build the container:

```sh
gcloud builds submit -t "gcr.io/${GOOGLE_CLOUD_PROJECT}/jobs-shell"
```

## Run locally

```sh
docker run --rm gcr.io/${GOOGLE_CLOUD_PROJECT}/jobs-shell

# Add a 1 second delay and fail the job with 90% chance.
docker run --rm -e FAIL_RATE=0.9 -e SLEEP_MS=1000 gcr.io/${GOOGLE_CLOUD_PROJECT}/jobs-shell
```

## Create a job
```
gcloud alpha run jobs create jobs-shell \
  --set-env-vars FAIL_RATE=0.4,SLEEP_MS=5000 \
  --max-retries 10 \
  --tasks 5 \
  --image "gcr.io/${GOOGLE_CLOUD_PROJECT}/jobs-shell"
```

## Execute the job
```
gcloud alpha run jobs execute jobs-shell --wait
```