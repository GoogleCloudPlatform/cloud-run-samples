# Locksmith

> Creates a service account key and stores it in Secret Manager... as a service.

This Cloud Function facilitates automatic creation of an exported service account key
with rotation by Cloud Scheduler. It has been created for use in the automated testing
of the cloud-run-samples repo.

## Setup

1. Set up the "test runner" service account:

    ```sh
    gcloud iam service-accounts create test-runner-identity
    RUNNER_EMAIL="test-runner-identity@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com"
    # Add invoker access to every Cloud Run service in the project.
    gcloud projects add-iam-policy-binding "${GOOGLE_CLOUD_PROJECT}" \
        --member "serviceAccount:${RUNNER_EMAIL}" \
        --role roles/run.invoker
    ```

1. Set up the Cloud Function identity to work with Secret Manager and Service Account keys:

    ```sh
    # Create the service account.
    gcloud iam service-accounts create locksmith-identity
    IDENTITY_EMAIL="locksmith-identity@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com"

    # Create the secret and grant the service account access to add new secret versions.
    gcloud secrets create locksmith-secret \
        --replication-policy "automatic"
        --labels component=locksmith
    gcloud secrets add-iam-policy-binding locksmith-secret \
        --member "serviceAccount:${IDENTITY_EMAIL}" \
        --role roles/secretmanager.admin

    # Create a restricted role that only allows creating Service Account keys.
    gcloud iam roles create keyholder \
        --project adamross-svls-kibble \
        --title "Key Holder" \
        --permissions iam.serviceAccountKeys.create
        --permissions iam.serviceAccountKeys.delete

    # Grant the service account for our Cloud Function the ability to create service account keys.
    # This is limited to creating keys for the test runner service account.
    gcloud iam service-accounts add-iam-policy-binding "${RUNNER_EMAIL}" \
        --member "serviceAccount:${IDENTITY_EMAIL}" \
        --role "projects/${GOOGLE_CLOUD_PROJECT}/roles/keyholder"
    ```

1. Deploy our Cloud Function with all needed configuration:

    ```sh
    gcloud functions deploy locksmith \
        --trigger-http \
        --runtime nodejs10 \
        --no-allow-unauthenticated \
        --service-account "${IDENTITY_EMAIL}" \
        # The function derives the complete secret and service account identifiers from
        # it's own runtime context.
        --update-env-vars SECRET_NAME=locksmith-secret \
        --update-env-vars RUNNER_SERVICE_ACCOUNT=test-runner-identity \
        --update-labels component=locksmith
    ```

1. Create the scheduled invoker:

    ```sh
    # Create a service account allowed to invoke the Cloud Function.
    gcloud iam service-accounts create locksmith-invoker
    INVOKER_EMAIL="locksmith-invoker@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com"
    gcloud functions add-iam-policy-binding locksmith \
        --member "serviceAccount:${INVOKER_EMAIL}" \
        --role roles/cloudfunctions.invoker

    # Create a job to run the function monthly.
    URI=$(gcloud functions describe locksmith --format 'value(httpsTrigger.url)')
    # "At minute 42 on every 28th day-of-month."
    gcloud scheduler jobs create http locksmith-job \
        --schedule "42 * */28 * *" \
        --uri "${URI}" \
        --oidc-service-account-email "${INVOKER_EMAIL}"
    ```

1. Enable Cloud Build to use these credentials:

```sh
PROJECT_NUMBER=gcloud projects describe $GOOGLE_CLOUD_PROJECT --format 'value(projectNumber)'
gcloud secrets add-iam-policy-binding locksmith-secret \
  --member "serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
  --role roles/secretmanager.secretAccessor
```

## Security Considerations

In reviewing the setup instructions, great care is taken to minimize security exposure.

1. The invoker can only invoke the locksmith function
1. The locksmith identity can only create service account keys for a single service account, and then only create or delete the keys. It can only manage a single secret.
1. If locksmith fails to save a new key to Secret Manager, it attempts to delete the new key.

In the specific configuration of Cloud Build to use this secret, it's only given access to the locksmith secret, blanket Secret Manager permission is not done here.

Security steps not taken:

* As new service account keys are created, previous keys are not actively purged. This may be considered in the future, but automatic retiring of older keys seems like something which should be handled as a blanket practice rather than built into the logic of this function.

## Using/Developing with Locksmith

To manually trigger an end to end run of the function use:

```sh
gcloud scheduler jobs run locksmith-job
```

To review end-to-end logs, my current search query is:

```text
(resource.type = "cloud_scheduler_job" resource.labels.job_id="locksmith-job")
  OR (resource.type="cloud_function" resource.labels.function_name="locksmith")
  OR (resource.type="audited_resource" resource.labels.service="secretmanager.googleapis.com" protoPayload.response.name:"locksmith-secret")
  OR (resource.type="service_account" resource.labels.email_id:"test-runner-identity")
```

## Revised Manual Trigger

There are several more substitutions now, once this is ready for final PR we'll need to revise the README.

```sh
gcloud builds submit \
  --config cloud-run-template.cloudbuild.yaml \
  --substitutions 'SHORT_SHA=manual,_RUNNER_IDENTITY=test-runner-identity@adamross-svls-kibble.iam.gserviceaccount.com,_SAMPLE_DIR=.,_SERVICE=test-locksmith,_SECRET_NAME=token-minter-secret'
```
