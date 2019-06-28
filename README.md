# Cloud Run Samples

This repository contains sample applications used in [Cloud Run](https://cloud.google.com/run) tutorials.

## Sample Index

|        Sample              |        Description                                         |     Languages                    |
| -------------------------- | ---------------------------------------------------------- | -------------------------------- |
| Identity Platform          | Cloud Run on GKE + Istio + Identity Platform               | [GKE][identity_platform_gke]
| Manual Logging             | Structured logging without client library                  | [Nodejs][manual_logging_nodejs]  |
| Pub/Sub Push               | Handle messages from a push subscription                   | [Nodejs][pubsub_nodejs], [Python][pubsub_python] |
| Service to Service Request | Snippet: Authenticated requests between Cloud Run services | [Go][authentication_go]          |
| Global State               | Snippet: Using global state for in-memory caching          | [Nodejs][global_state_nodejs]    |
| Lazy Initialization        | Snippet: Global state and lazy loading faster cold start   | [Nodejs][global_lazy_nodejs]     |
| Ultra-minimal Web Server   | A zero-source, "hello, world" web server                   | -none-                           |

## Contributing changes

Entirely new samples are not accepted. Bug fixes are welcome, either as pull
requests or as GitHub issues.

See [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to contribute.

## Licensing

Code in this repository is licensed under the Apache 2.0. See [LICENSE](LICENSE).

[identity_platform_gke]: identity-platform/gke
[manual_logging_nodejs]: https://github.com/GoogleCloudPlatform/nodejs-docs-samples/tree/master/run/logging-manual
[pubsub_nodejs]: https://github.com/GoogleCloudPlatform/nodejs-docs-samples/tree/master/run/pubsub
[pubsub_python]: https://github.com/GoogleCloudPlatform/python-docs-samples/tree/master/run/pubsub
[authentication_go]: https://github.com/GoogleCloudPlatform/golang-samples/tree/master/run/authentication
[global_state_nodejs]: https://github.com/GoogleCloudPlatform/nodejs-docs-samples/blob/master/functions/tips/index.js#L33
[global_lazy_nodejs]: https://github.com/GoogleCloudPlatform/nodejs-docs-samples/blob/master/functions/tips/index.js#L55
