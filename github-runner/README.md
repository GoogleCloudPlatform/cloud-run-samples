# Host GitHub runners with Cloud Run worker pools

This sample supports the tutorial [Host GitHub runners with Cloud Run worker pools](https://cloud.google.com/run/docs/tutorials/github-runner).

This code contains two folders:

 * `worker-pool-container`: the code used to build the container for the worker pool.
 * `autoscaler`: the code for the Cloud Run function which autoscales the pool.
