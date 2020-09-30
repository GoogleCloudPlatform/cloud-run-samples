# Cloud Run Samples

This repository contains sample applications used in [Cloud Run](https://cloud.google.com/run) documentation.

## Sample Index

|          Sample            |                     Description                         |              Languages             |
| -------------------------- | ------------------------------------------------------- | ---------------------------------- |
| Knative Hello World        | Hello World! A quickstart sample collection.            | [Go][hello_go], [Node.js][hello_nodejs], [Python][hello_python], [Java Spring Boot][hello_java_spring], [Java Spark][hello_java_spark], [C#][hello_csharp], [PHP][hello_php], [Ruby][hello_ruby], [Kotlin][hello_kotlin], [Scala][hello_scala], [Shell][hello_shell] |
| Manual Logging             | Structured logging without client library               | [Go][manual_logging_go], [Node.js][manual_logging_nodejs], [Python][manual_logging_python], [Java][manual_logging_java]|
| System Package             | Use system-installed binaries.                          | [Go][system_package_go], [Node.js][system_package_nodejs], [Java][system_package_java]                                 |
| Pub/Sub Push               | Handle messages from a push subscription                | [Go][pubsub_go], [Node.js][pubsub_nodejs], [Python][pubsub_python], [Java][pubsub_java] |
| Image Processing           | Event-driven image analysis & transformation            | [Go][imageproc_go], [Node.js][imageproc_nodejs], [Python][imageproc_python], [Java][imageproc_java]                 |
| Cloud SQL (MySQL)          | Use MySQL with Cloud Run                                | [Node.js][mysql_nodejs], [Python][mysql_python]             |
| Cloud SQL (Postgres)       | Use Postgres with Cloud Run                             | [Node.js][postgres_nodejs], [Python][postgres_python] |  
| Service to Service Request | Snippet: Authenticated requests between services        | [Go][authentication_go]          |
| Global State               | Snippet: Using global state for in-memory caching       | [Go][global_state_go], [Nodejs][global_state_nodejs]      |
| Lazy Initialization        | Snippet: Lazy loading faster cold start                 | [Go][global_lazy_go], [Nodejs][global_lazy_nodejs]       |
| Identity Platform          | Cloud Run for Anthos + Istio + Identity Platform        | [GKE][identity_platform_gke]     |
| Istio Authorization        | Cloud Run for Anthos + Istio Role-Based Access Control  | [GKE][istio_authorization]       |
| Hello Broken               | "Broken" service for troubleshooting.                   | [Go][broken_go], [Node.js][broken_nodejs]            |
| VPC sample                 | Sample showing egress & ingress settings with VPC       | [Python][vpc-sample]

[hello_go]: https://github.com/knative/docs/tree/master/docs/serving/samples/hello-world/helloworld-go
[hello_nodejs]: https://github.com/knative/docs/tree/master/docs/serving/samples/hello-world/helloworld-nodejs
[hello_python]: https://github.com/knative/docs/tree/master/docs/serving/samples/hello-world/helloworld-python
[hello_java_spring]: https://github.com/knative/docs/tree/master/docs/serving/samples/hello-world/helloworld-java-spring
[hello_java_spark]: https://github.com/knative/docs/tree/master/docs/serving/samples/hello-world/helloworld-java-spark
[hello_csharp]: https://github.com/knative/docs/tree/master/docs/serving/samples/hello-world/helloworld-csharp
[hello_php]: https://github.com/knative/docs/tree/master/docs/serving/samples/hello-world/helloworld-php
[hello_ruby]: https://github.com/knative/docs/tree/master/docs/serving/samples/hello-world/helloworld-ruby
[hello_kotlin]: https://github.com/knative/docs/tree/master/docs/serving/samples/hello-world/helloworld-kotlin
[hello_scala]: https://github.com/knative/docs/tree/master/docs/serving/samples/hello-world/helloworld-scala
[hello_shell]: https://github.com/knative/docs/tree/master/docs/serving/samples/hello-world/helloworld-shell
[manual_logging_go]: https://github.com/GoogleCloudPlatform/golang-samples/tree/master/run/logging-manual
[manual_logging_nodejs]: https://github.com/GoogleCloudPlatform/nodejs-docs-samples/tree/master/run/logging-manual
[manual_logging_python]: https://github.com/GoogleCloudPlatform/python-docs-samples/tree/master/run/logging-manual
[manual_logging_java]: https://github.com/GoogleCloudPlatform/java-docs-samples/tree/master/run/logging-manual
[system_package_go]: https://github.com/GoogleCloudPlatform/golang-samples/tree/master/run/system_package
[system_package_nodejs]: https://github.com/GoogleCloudPlatform/nodejs-docs-samples/tree/master/run/system-package
[system_package_java]: https://github.com/GoogleCloudPlatform/java-docs-samples/tree/master/run/system-package
[pubsub_go]: https://github.com/GoogleCloudPlatform/golang-samples/tree/master/run/pubsub
[pubsub_nodejs]: https://github.com/GoogleCloudPlatform/nodejs-docs-samples/tree/master/run/pubsub
[pubsub_python]: https://github.com/GoogleCloudPlatform/python-docs-samples/tree/master/run/pubsub
[pubsub_java]: https://github.com/GoogleCloudPlatform/java-docs-samples/tree/master/run/pubsub
[imageproc_go]: https://github.com/GoogleCloudPlatform/golang-samples/tree/master/run/image-processing
[imageproc_nodejs]: https://github.com/GoogleCloudPlatform/nodejs-docs-samples/tree/master/run/image-processing
[imageproc_python]: https://github.com/GoogleCloudPlatform/python-docs-samples/tree/master/run/image-processing
[imageproc_java]: https://github.com/GoogleCloudPlatform/java-docs-samples/tree/master/run/image-processing
[mysql_nodejs]: https://github.com/GoogleCloudPlatform/nodejs-docs-samples/tree/master/cloud-sql/mysql/mysql
[mysql_python]: https://github.com/GoogleCloudPlatform/python-docs-samples/tree/master/cloud-sql/mysql/sqlalchemy
[postgres_nodejs]: https://github.com/GoogleCloudPlatform/nodejs-docs-samples/tree/master/cloud-sql/postgres/knex
[postgres_python]: https://github.com/GoogleCloudPlatform/python-docs-samples/tree/master/cloud-sql/postgres/sqlalchemy
[authentication_go]: https://github.com/GoogleCloudPlatform/golang-samples/tree/master/run/authentication
[global_state_go]: https://github.com/GoogleCloudPlatform/golang-samples/blob/master/functions/tips/scope.go
[global_state_nodejs]: https://github.com/GoogleCloudPlatform/nodejs-docs-samples/blob/master/functions/tips/index.js#L33
[global_lazy_go]: https://github.com/GoogleCloudPlatform/golang-samples/blob/master/functions/tips/lazy.go
[global_lazy_nodejs]: https://github.com/GoogleCloudPlatform/nodejs-docs-samples/blob/master/functions/tips/index.js#L55
[identity_platform_gke]: identity-platform/gke
[istio_authorization]: istio-authorization
[broken_go]: https://github.com/GoogleCloudPlatform/golang-samples/tree/master/run/hello-broken
[broken_nodejs]: https://github.com/GoogleCloudPlatform/nodejs-docs-samples/tree/master/run/hello-broken
[vpc-sample]: vpc-sample

**Samples by Language**: [nodejs][nodejs], [golang][golang], [python][python], [java][java]

[nodejs]: https://github.com/GoogleCloudPlatform/nodejs-docs-samples/tree/master/run#readme
[golang]: https://github.com/GoogleCloudPlatform/golang-samples/tree/master/run#readme
[python]: https://github.com/GoogleCloudPlatform/python-docs-samples/tree/master/run#readme
[java]: https://github.com/GoogleCloudPlatform/java-docs-samples/tree/master/run#readme

## Deploy a sample with a button click!

The [Cloud Run Button](https://github.com/GoogleCloudPlatform/cloud-run-button)
makes your Cloud Run service deployable with the push of a button. (It will open a Cloud Shell window.)

|        Sample             |                         Cloud Run Button                        |        Details from the Cloud Run Documentation                 | 
| ------------------------- | --------------------------------------------------------------- | --------------------------------------------------------------- | 
| Knative Hello World (Python) | [<img src="https://storage.googleapis.com/cloudrun/button.svg" alt="Run on Google Cloud" height="30">][run_button_hello] | -   |
| Manual Logging (Node.js)  | [<img src="https://storage.googleapis.com/cloudrun/button.svg" alt="Run on Google Cloud" height="30">][run_button_manual_logging] |  [Logging guide][docs_logging] |
| System Package (Go)       | [<img src="https://storage.googleapis.com/cloudrun/button.svg" alt="Run on Google Cloud" height="30">][run_button_system_package] | [Using system packages tutorial][docs_system_package] |
| Pub/Sub Push (Go)         | [<img src="https://storage.googleapis.com/cloudrun/button.svg" alt="Run on Google Cloud" height="30">][run_button_pubsub]         | [Pub/Sub tutorial][docs_pubsub] |
| Image Processing (Go)     | [<img src="https://storage.googleapis.com/cloudrun/button.svg" alt="Run on Google Cloud" height="30">][run_button_imageproc]         | [Image Processing tutorial][docs_imageproc] |
| Hello Broken (Node.js)    | [<img src="https://storage.googleapis.com/cloudrun/button.svg" alt="Run on Google Cloud" height="30">][run_button_broken]         | Forthcoming |

[run_button_hello]: https://deploy.cloud.run/?git_repo=https://github.com/knative/docs&dir=docs/serving/samples/hello-world/helloworld-python
[run_button_manual_logging]: https://deploy.cloud.run/?git_repo=https://github.com/GoogleCloudPlatform/nodejs-docs-samples&dir=run/logging-manual
[run_button_system_package]: https://deploy.cloud.run/?git_repo=https://github.com/GoogleCloudPlatform/golang-samples&dir=run/system_package
[run_button_pubsub]: https://deploy.cloud.run/?git_repo=https://github.com/GoogleCloudPlatform/golang-samples&dir=run/pubsub
[run_button_imageproc]: https://deploy.cloud.run/?git_repo=https://github.com/GoogleCloudPlatform/golang-samples&dir=run/image-processing
[run_button_broken]: https://deploy.cloud.run/?git_repo=https://github.com/GoogleCloudPlatform/nodejs-docs-samples&dir=run/hello-broken

[docs_logging]: https://cloud.google.com/run/docs/logging
[docs_system_package]: https://cloud.google.com/run/docs/tutorials/system-packages
[docs_pubsub]: https://cloud.google.com/run/docs/tutorials/pubsub
[docs_imageproc]: https://cloud.google.com/run/docs/tutorials/image-processing

## Contributing changes

Entirely new samples are not accepted. Bug fixes are welcome, either as pull
requests or as GitHub issues.

See [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to contribute.

## Licensing

Code in this repository is licensed under the Apache 2.0. See [LICENSE](LICENSE).
