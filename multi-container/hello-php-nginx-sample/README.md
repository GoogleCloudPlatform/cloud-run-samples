# Deploy simple nginx multi-container service NGINX/PHP-FPM

A Google Cloud Project is required in order to run the sample. 

## Enable required APIs

The project should have the following API's enabled:

* Cloud Run

```bash
gcloud services enable run.googleapis.com
```

### gcloud CLI

```bash
make login # authenticate & create Artifact Registry repo

make build # build nginx & php images to Artifact Registry

make deploy # deploys multi-container service with nginx/php containers
```

## Deploy the multi-container service

From inside the `hello-php-nginx-sample` directory, declare an environment variable `MC_SERVICE_NAME` to 
store your custom service name string. 

```sh
export MC_SERVICE_NAME=<service-name>
export REGION="us-central1"
export REPO_NAME="default"

# Substituting above env vars
sed -i -e s/MC_SERVICE_NAME/${MC_SERVICE_NAME}/g -e s/REGION/${REGION}/g -e s/REPO_NAME/${REPO_NAME} service.yaml

# Deploy your service
gcloud run services replace service.yaml
```

By default, the above command will deploy the following containers into a single service:

* `nginx`: `serving` ingress container (entrypoint)
* `hellophp`: `sidecar` container

The Cloud Run Multi-container service will default access to port `8080`,
where `nginx` container will be listening and proxy request over to `hello` container at port `9000`.

## Try it out

Use curl to send an authenticated request:

```bash
curl --header "Authorization: Bearer $(gcloud auth print-identity-token)" <cloud-run-mc-service-url>
```

### Allow unauthenticated requests

To allow un-authenticated access to containers:

```bash
gcloud run services add-iam-policy-binding $MC_SERVICE_NAME \
    --member="allUsers" \
    --role="roles/run.invoker"
```

Visit the Cloud Run url or use curl to send a request:

```bash
curl <cloud-run-mc-service-url>
```

## Find out more:

* https://cloud.google.com/run/docs/deploying#sidecars
* https://cloud.google.com/blog/products/serverless/cloud-run-now-supports-multi-container-deployments

