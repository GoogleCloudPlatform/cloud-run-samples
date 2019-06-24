# Authenticating Cloud Run on GKE end users using Istio and Identity Platform

This directory contains the sample code used in the tutorial
[Authenticating Cloud Run on GKE end users using Istio and Identity Platform](https://cloud.google.com/run/docs/authenticating/identity-platform-gke).
The tutorial demonstrates how to authenticate end users to applications
deployed to [Cloud Run on GKE](https://cloud.google.com/run/) using
[Istio authentication policies](https://istio.io/docs/concepts/security/#authentication-policies)
and [Identity Platform](https://cloud.google.com/identity-platform/).

## Instructions

Follow the steps below to create the GCP resources used in the tutorial.

1. Open Cloud Shell:

    [![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/cloud-run-samples.git&cloudshell_working_dir=identity-platform/gke&cloudshell_tutorial=README.md)

2. Define environment variables for the GKE cluster name and Compute Engine
    zone:

        CLUSTER=cloud-run-gke-auth-tutorial
        ZONE=us-central1-c

3. Create a GKE cluster with the Cloud Run and Istio add-ons:

        gcloud beta container clusters create $CLUSTER \
            --addons HttpLoadBalancing,Istio,CloudRun \
            --cluster-version 1.13 \
            --enable-ip-alias \
            --enable-stackdriver-kubernetes \
            --machine-type n1-standard-4
            --zone $ZONE

4. Go to the
    [Identity Platform Marketplace page](https://console.cloud.google.com/marketplace/details/google-cloud-platform/customer-identity).

5. Turn on Identity Platform by clicking **Enable Identity Platform**.

6. Click the Application **setup details** link on the
    **Identity Platform > Providers** page.

7. In Cloud Shell, define environment variables for the Identity Platform
    credentials in the **Configure your application** popup:

        export AUTH_APIKEY=[your Identity Platform apiKey]
        export AUTH_DOMAIN=[your Identity Platform authDomain]

8. Substitute the Identity Platform credentials in the frontend JavaScript
    file:

        envsubst < frontend/index.template.js > frontend/index.js

    (If you are _not_ using Cloud Shell,
    [install `envsubst`](https://github.com/a8m/envsubst/blob/master/README.md#installation).)

9. Use [Cloud Build](https://cloud.google.com/cloud-build/) to create
    container images for the sample application frontend and backend and
    store them in
    [Container Registry](https://cloud.google.com/container-registry/):

        gcloud builds submit frontend \
            -t gcr.io/$GOOGLE_CLOUD_PROJECT/cloud-run-gke-auth-frontend

        gcloud builds submit backend \
            -t gcr.io/$GOOGLE_CLOUD_PROJECT/cloud-run-gke-auth-backend

10. Create two namespaces called `public` and `api`:

        kubectl create namespace public

        kubectl create namespace api

11. Deploy the frontend container image to Cloud Run on GKE as a service in
    the `public` namespace:

        gcloud beta run deploy frontend \
            --namespace public \
            --image gcr.io/$GOOGLE_CLOUD_PROJECT/cloud-run-gke-auth-frontend \
            --platform gke \
            --cluster $CLUSTER \
            --cluster-location $ZONE

12. Deploy the backend container image to Cloud Run on GKE as a service in
    the `api` namespace:

        gcloud beta run deploy backend \
            --namespace api \
            --image gcr.io/$GOOGLE_CLOUD_PROJECT/cloud-run-gke-auth-backend \
            --platform gke \
            --cluster $CLUSTER \
            --cluster-location $ZONE

13. Create an
    [Istio virtual service](https://archive.istio.io/v1.1/docs/reference/config/networking/v1alpha3/virtual-service/)
    that routes requests by URI path:

        kubectl apply -f istio/virtualservice.yaml

14. Create an
    [Istio authentication policy](https://archive.istio.io/v1.1/docs/reference/config/istio.authentication.v1alpha1/):

        envsubst < istio/authenticationpolicy.template.yaml | \
            kubectl apply -f -

15. Follow the steps in the
    [tutorial](https://cloud.google.com/run/docs/authenticating/identity-platform-gke)
    to create a test user and verify the solution.

## Cleaning up

1. Delete the container images from Container Registry:

        gcloud container images list-tags \
            gcr.io/$GOOGLE_CLOUD_PROJECT/cloud-run-gke-auth-backend \
            --format 'value(digest)' | \
            xargs -I {} gcloud container images delete \
            --force-delete-tags --quiet \
            gcr.io/$GOOGLE_CLOUD_PROJECT/cloudrun-gke-auth-backend@sha256:{}

        gcloud container images list-tags \
            gcr.io/$GOOGLE_CLOUD_PROJECT/cloud-run-gke-auth-frontend \
            --format 'value(digest)' | \
            xargs -I {} gcloud container images delete \
            --force-delete-tags --quiet \
            gcr.io/$GOOGLE_CLOUD_PROJECT/cloudrun-gke-auth-frontend@sha256:{}

2. Delete the GKE cluster:

        gcloud container clusters delete $CLUSTER --zone $ZONE --async --quiet

## Disclaimer

This is not an officially supported Google product.
