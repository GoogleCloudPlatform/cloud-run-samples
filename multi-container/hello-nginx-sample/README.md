# Deploy simple nginx multi-container service

A Google Cloud Project is required in order to run the sample. 

## Enable required APIs

The project should have the following API's enabled:

* Cloud Run
* Secret Manager

```bash
gcloud services enable secretmanager.googleapis.com run.googleapis.com
```

## Add nginx server configuration to Secret Manager

Instead of packaging the [nginx](https://www.nginx.com/) config into the container image, the config will be mounted as a volume at runtime
using [Secret Manager](https://cloud.google.com/secret-manager). This allows for separation of config from code.

In Kubernetes, while you are able to [mount different volume types](https://kubernetes.io/docs/concepts/storage/volumes/), 
[Cloud Run](https://cloud.google.com/run/docs/reference/yaml/v1) currently provides `secret` volume as a lightweight volume mount. If you need a full filesystem, see [Using network file systems](https://cloud.google.com/run/docs/using-network-file-systems).
In [`service.yaml`](./service.yaml), look for `nginx-conf-secret` volume mount and `nginx_config` secret name references.

Follow along either using the `gcloud` commands in your terminal or the Google Cloud Console site to add the `nginx_config` secret.

### gcloud CLI

The following creates a new secret in Secret Manager and adds value (new version) from local file `nginx.conf`.

```bash
gcloud secrets create nginx_config --replication-policy="automatic" --data-file="./nginx.conf"
```

Grant your compute service account to have access to your newly created secret.

```bash
export PROJECT_NUMBER=$(gcloud projects describe $(gcloud config get-value project) --format='value(projectNumber)')
gcloud secrets add-iam-policy-binding nginx_config --member=serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com --role='roles/secretmanager.secretAccessor'
```

**OR** 

### Console UI

* Go to the [Secret Manager UI](https://console.cloud.google.com/security/secret-manager)
* Select `+ Create Secret` and name it `nginx_config` with the contents of `nginx.conf`
* Click `Create Secret`

## Deploy the multi-container service

From inside the `hello-nginx-sample` directory, declare an environment variable `MC_SERVICE_NAME` to 
store your custom service name string. 

On your local machine, install `gettest-base` module to use `envsubstr`, 
which will be used form  environment variable substitution in `mc-service-template.yaml`. 

```sh
export MC_SERVICE_NAME=<service-name>
export REGION = us-central-11

# Substituting above env vars and storing into new file
envsubstr < mc-service-template.yaml > service.yaml

# Deploy your service
gcloud run services replace service.yaml
```

By default, the above command will deploy the following containers into a single service:

* `nginx`: `serving` ingress container (entrypoint)
* `hello`: `sidecar` container

The Cloud Run Multi-container service will default access to port `8080`,
where `nginx` container will be listening and proxy request over to `hello` container at port `8888`.

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
