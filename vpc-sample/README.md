# Using egress and ingress settings to restrict access to services 

A Google Cloud Project is required in order to run the sample. The project should have the following API's enabled:

* Cloud Run
* Artifact Registry
* Serverless VPC Access API 

## Set your environment up

Declare required environment variables before proceeding.

```sh
export PROJECT_ID=<project-id> # GCP project id
export REGION=us-central1 # GCP service region
```

Enable relevant Google Cloud APIs:

```sh
gcloud services enable \
  vpcaccess.googleapis.com \
  artifactregistry.googleapis.com \
  cloudbuild.googleapis.com \
  run.googleapis.com
```

## Create Serverless VPC access connector

```sh
gcloud compute networks vpc-access connectors create serverless-connector \
    --region=${REGION} \
    --range=10.8.0.0/28
```

## Deploy the restricted Cloud Run Service (ingress only)

From inside the `vpc-sample/run-ingress` directory:

```sh
gcloud run deploy restricted-service \
    --source=. \
    --ingress=internal \
    --no-allow-unauthenticated
```

The `-ingress=internal` will restrict access to this Cloud Run services to other services inside the project.
To call this service, deploy another Cloud Run service with the egress going through a VPC connector.


## Deploy the Cloud Run service (egress) with a vpc connector

From inside the `vpc-sample/run-egress` directory:

Replace the following before deploying:
* `restricted-service-url`: Cloud Run URL provided to you when you deployed ingress service (i.e restricted-service-abc-uc.a.run.app)

```sh
gcloud run deploy run-egress \
    --source=. \
    --no-allow-unauthenticated \
    --update-env-vars=URL=<restricted-service-url> \
    --vpc-egress=all \
    --vpc-connector=serverless-connector
    --region=$REGION
```

The Cloud Run sends a get request via the VPC connector to the network-restricted service.
