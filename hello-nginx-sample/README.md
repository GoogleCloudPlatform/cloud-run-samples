# Deploy multi-container service using nginx

A Google Cloud Project is required in order to run the sample. The project should have the following API's enabled:

* Cloud Run
* Secret Manager

## Enable required APIs

```sh
gcloud services enable secretmanager.googleapis.com run.googleapis.com
```

## Create new secret in Secret Manager

* Go to the [Secret Manager UI](https://console.cloud.google.com/security/secret-manager)
* Select `+ Create Secret` and name it `nginx_config` with the following secret value:

```conf
server {
    listen 8080; # Listen at port 8080
    server_name _; # Server at localhost
    gzip on; # Enables gzip compression to make our app faster

    location / {
        proxy_pass   http://127.0.0.1:8888; # Passing requests to 8080 to proxy server at port 8888
    }
}
```

* Click `Create Secret`

## Deploy the multi-container service

From inside the `hello-nginx-sample` directory:

```sh
gcloud run services replace multicontainers.yaml
```

By default, the above command will deploy the following containers into a single service:

* `nginx`: `serving` ingress container (entrypoint)
* `hello`: `sidecar` container

The Cloud Run Multi-container service will default access to port `8080`,
where `nginx` container will be listenting, to only proxy over to `hello` container at port `8888`.

## Find out more:

* https://cloud.google.com/run/docs/deploying#sidecars
* https://cloud.google.com/blog/products/serverless/cloud-run-now-supports-multi-container-deployments
