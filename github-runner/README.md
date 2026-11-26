# Host GitHub runners with Cloud Run worker pools

This sample supports the tutorial [Host GitHub runners with Cloud Run worker pools](https://cloud.google.com/run/docs/tutorials/github-runner).

This code contains three folders:

 * `worker-pool-container`: the code used to build the container for the worker pool.
 * `autoscaler`: the code for the Cloud Run function which autoscales the pool.
 * `terraform-crema`: production-ready Terraform deployment using [CREMA (Cloud Run External Metrics Autoscaling)](https://github.com/GoogleCloudPlatform/cloud-run-external-metrics-autoscaling), GitHub App Just-In-Time (JIT) ephemeral runner registration, Regional Parameter Manager, and Secret Manager.
