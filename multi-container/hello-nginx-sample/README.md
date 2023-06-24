# Deploy simple nginx multi-container service

A Google Cloud Project is required in order to run the sample. 

## Enable required APIs

The project should have the following API's enabled:

* Cloud Run
* Secret Manager

```bash
gcloud services enable secretmanager.googleapis.com run.googleapis.com

## Add nginx server configuration to Secret Manager

Utilize [Secret Manager](https://cloud.google.com/secret-manager) to store and mount the [nginx](https://www.nginx.com/) server configuration.

In Kubernetes, while you are able to [mount different volume types](https://kubernetes.io/docs/concepts/storage/volumes/), 
[Cloud Run](https://cloud.google.com/run/docs/reference/yaml/v1) currently provides `secret` volume as a lightweight volume mount. If you need a full filesystem, see [Using network file systems](https://cloud.google.com/run/docs/using-network-file-systems).
In [`service.yaml`](./service.yaml), look for `nginx-conf-secret` volume mount and `nginx_config` secret name references.

Follow along either using the `gcloud` commands in your terminal or the Google Cloud Console site to add the `nginx_config` secret.

### gcloud CLI

The following creates a new secret in Secret Manager and adds value (new version) from local file `nginx.conf`.

```bash
gcloud secrets create nginx_conf --replication-policy="automatic" --data-file="./nginx.conf"
```

**OR** 

### Console UI

* Go to the [Secret Manager UI](https://console.cloud.google.com/security/secret-manager)
* Select `+ Create Secret` and name it `nginx_config` with the contents of `nginx.conf`
* Click `Create Secret`

## Deploy the multi-container service

From inside the `hello-nginx-sample` directory:

```sh
gcloud run services replace service.yaml
```

By default, the above command will deploy the following containers into a single service:

* `nginx`: `serving` ingress container (entrypoint)
* `hello`: `sidecar` container

### Update container policy

To allow un-authenticated access to containers.

```bash
gcloud run services set-iam-policy nginx-example policy.yaml
```

The Cloud Run Multi-container service will default access to port `8080`,
where `nginx` container will be listening and proxy request over to `hello` container at port `8888`.

## Find out more:

* https://cloud.google.com/run/docs/deploying#sidecars
* https://cloud.google.com/blog/products/serverless/cloud-run-now-supports-multi-container-deployments
