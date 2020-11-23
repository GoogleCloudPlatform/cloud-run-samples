# Using egress and ingress settings to restrict access to services 

A Google Cloud Project is required in order to run the sample. The project should have the following API's enabled:

* Cloud Run
* Cloud Functions
* Serverless VPC Access API 

## Deploy the Function 

From inside the vpc-sample directory:

```sh
gcloud functions deploy restricted-function \
--runtime=python38 --trigger-http --no-allow-unauthenticated \
--ingress-settings=internal-only --entry-point=hello_world
```

The `-ingress-settings=internal-only` will restrict access to the function to services inside the project.  To call the function, deploy a service with the egress going through a VPC connector.

## Create Serverless VPC access connector

```sh
gcloud compute networks vpc-access connectors create serverless-connector \
--region=${_SERVICE_REGION} --range=10.8.0.0/28
```

## Build and Deploy the Cloud Run Function with a vpc connector

From inside the vpc-sample directory:

```sh
gcloud builds submit --tag=gcr.io/${PROJECT_ID}/restricted-function-caller . 
```

```sh
gcloud alpha run deploy run-function --image gcr.io/${PROJECT_ID}/restricted-function-caller \
--no-allow-unauthenticated --platform managed \
--update-env-vars=URL=https://${_SERVICE_REGION}-$PROJECT_ID.cloudfunctions.net/restricted-function-caller \
--vpc-egress=all --vpc-connector=serverless-connector --region=${_SERVICE_REGION}
```

The Cloud Run function sends a get request via the VPC connector to the network-restricted function.
