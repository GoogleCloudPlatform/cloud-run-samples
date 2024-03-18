# Cloud Run Samples

This repository contains sample applications used in [Cloud Run](https://cloud.google.com/run) documentation.

## Sample Index

For all Cloud Run code samples, see the [Cloud Run sample browser](https://cloud.google.com/run/docs/samples).

|          Sample            |                     Description                         |              Languages             |
| -------------------------- | ------------------------------------------------------- | ---------------------------------- |
| Hello World service        | Hello World! A quickstart sample collection             | [Go][hello_go], [Node.js][hello_nodejs], [Python][hello_python], [Java][hello_java], [PHP][hello_php], [Ruby][hello_ruby], [Shell][hello_shell], [C++][hello_cpp] |
| Hello World job            | Job quickstart samples                                  | [Go][job_go], [Node.js][job_nodejs], [Python][job_python], [Java][job_java], [Shell][job_shell] |
| Manual Logging             | Structured logging without client library               | [Go][manual_logging_go], [Node.js][manual_logging_nodejs], [Python][manual_logging_python], [Java][manual_logging_java]|
| System Package             | Use system-installed binaries.                          | [Go][system_package_go], [Node.js][system_package_nodejs], [Java][system_package_java], [Python][system_package_python]|
| Pub/Sub Push               | Handle messages from a push subscription                | [Go][pubsub_go], [Node.js][pubsub_nodejs], [Python][pubsub_python], [Java][pubsub_java] |
| Image Processing           | Event-driven image analysis & transformation            | [Go][imageproc_go], [Node.js][imageproc_nodejs], [Python][imageproc_python], [Java][imageproc_java] |
| Cloud SQL (MySQL)          | Use MySQL with Cloud Run                                | [Node.js][mysql_nodejs], [Python][mysql_python], [Java][mysql_java] |
| Cloud SQL (Postgres)       | Use Postgres with Cloud Run                             | [Node.js][postgres_nodejs], [Python][postgres_python], [Java][postgres_java] |
| Global State               | Snippet: Using global state for in-memory caching       | [Go][global_state_go], [Nodejs][global_state_nodejs], [Python][global_state_python], [Java][global_state_java] |
| Lazy Initialization        | Snippet: Lazy loading faster cold start                 | [Go][global_lazy_go], [Nodejs][global_lazy_nodejs], [Python][global_lazy_python], [Java][global_lazy_java] |
| Hello Broken               | "Broken" service for troubleshooting.                   | [Go][broken_go], [Node.js][broken_nodejs], [Java][broken_java], [Python][broken_python] |
| End user authentication    | Integrate with Identity Platform to restrict access     | [Node.js][idp_sql_nodejs], [Java][idp_sql_java], [Python][idp_sql_python] |
| Invoking with gRPC         | Demonstrates service-to-service gRPC requests           | [Go][grpc_go] |
| Service to Service Request | Snippet: Authenticated requests between services        | [Go][idtoken_request_go], [Node.js][idtoken_request_nodejs], [Python][idtoken_request_python], [Java][idtoken_request_java] |
| gcloud as a service        | Use `gcloud` and `gsutil` in a service                  | [Go][gcloud_report]                 |
| VPC Testing                | Egress and ingress settings with VPC                    | [Python][vpc_sample]                |
| Multi-container Hello Nginx| Multi-containers with nginx                             | [YAML][multicontainer_hello_nginx_sample] |
| Open Policy Agent          | Open Policy Agent Multi-container                       | [YAML][multicontainer_open_policy_agent_sample]                |
| Markdown Preview           | 2 tier secure microservices for Markdown rendering      | [Go][markdown_preview_go], [Nodejs][markdown_preview_nodejs], [Python][markdown_preview_python], [Java][markdown_preview_java] |

[job_go]: https://github.com/GoogleCloudPlatform/golang-samples/tree/main/run/jobs
[job_nodejs]: https://github.com/GoogleCloudPlatform/nodejs-docs-samples/tree/main/run/jobs
[job_python]: https://github.com/GoogleCloudPlatform/python-docs-samples/tree/main/run/jobs
[job_java]: https://github.com/GoogleCloudPlatform/java-docs-samples/tree/main/run/jobs
[job_shell]: jobs-shell
[hello_go]: https://github.com/GoogleCloudPlatform/golang-samples/tree/main/run/helloworld
[hello_nodejs]: https://github.com/GoogleCloudPlatform/nodejs-docs-samples/tree/main/run/helloworld
[hello_python]: https://github.com/GoogleCloudPlatform/python-docs-samples/tree/main/run/helloworld
[hello_java]: https://github.com/GoogleCloudPlatform/java-docs-samples/tree/main/run/helloworld
[hello_php]: https://github.com/GoogleCloudPlatform/php-docs-samples/tree/main/run/helloworld
[hello_ruby]: https://github.com/GoogleCloudPlatform/ruby-docs-samples/tree/main/run/helloworld
[hello_cpp]: https://github.com/GoogleCloudPlatform/cpp-samples/tree/master/cloud-run-hello-world
[hello_shell]: helloworld-shell
[manual_logging_go]: https://github.com/GoogleCloudPlatform/golang-samples/tree/main/run/logging-manual
[manual_logging_nodejs]: https://github.com/GoogleCloudPlatform/nodejs-docs-samples/tree/main/run/logging-manual
[manual_logging_python]: https://github.com/GoogleCloudPlatform/python-docs-samples/tree/main/run/logging-manual
[manual_logging_java]: https://github.com/GoogleCloudPlatform/java-docs-samples/tree/main/run/logging-manual
[system_package_go]: https://github.com/GoogleCloudPlatform/golang-samples/tree/main/run/system_package
[system_package_nodejs]: https://github.com/GoogleCloudPlatform/nodejs-docs-samples/tree/main/run/system-package
[system_package_java]: https://github.com/GoogleCloudPlatform/java-docs-samples/tree/main/run/system-package
[system_package_python]: https://github.com/GoogleCloudPlatform/python-docs-samples/tree/main/run/system-package
[pubsub_go]: https://github.com/GoogleCloudPlatform/golang-samples/tree/main/run/pubsub
[pubsub_nodejs]: https://github.com/GoogleCloudPlatform/nodejs-docs-samples/tree/main/run/pubsub
[pubsub_python]: https://github.com/GoogleCloudPlatform/python-docs-samples/tree/main/run/pubsub
[pubsub_java]: https://github.com/GoogleCloudPlatform/java-docs-samples/tree/main/run/pubsub
[imageproc_go]: https://github.com/GoogleCloudPlatform/golang-samples/tree/main/run/image-processing
[imageproc_nodejs]: https://github.com/GoogleCloudPlatform/nodejs-docs-samples/tree/main/run/image-processing
[imageproc_python]: https://github.com/GoogleCloudPlatform/python-docs-samples/tree/main/run/image-processing
[imageproc_java]: https://github.com/GoogleCloudPlatform/java-docs-samples/tree/main/run/image-processing
[mysql_nodejs]: https://github.com/GoogleCloudPlatform/nodejs-docs-samples/tree/main/cloud-sql/mysql/mysql
[mysql_python]: https://github.com/GoogleCloudPlatform/python-docs-samples/tree/main/cloud-sql/mysql/sqlalchemy
[mysql_java]: https://github.com/GoogleCloudPlatform/java-docs-samples/tree/main/cloud-sql/mysql/servlet
[postgres_nodejs]: https://github.com/GoogleCloudPlatform/nodejs-docs-samples/tree/main/cloud-sql/postgres/knex
[postgres_python]: https://github.com/GoogleCloudPlatform/python-docs-samples/tree/main/cloud-sql/postgres/sqlalchemy
[postgres_java]: https://github.com/GoogleCloudPlatform/java-docs-samples/tree/main/cloud-sql/postgres/servlet
[authentication_go]: https://github.com/GoogleCloudPlatform/golang-samples/tree/main/run/authentication
[authentication_java]: https://github.com/GoogleCloudPlatform/java-docs-samples/tree/main/run/authentication
[global_state_go]: https://github.com/GoogleCloudPlatform/golang-samples/blob/master/functions/tips/scope.go
[global_state_python]: https://github.com/GoogleCloudPlatform/python-docs-samples/blob/main/functions/tips-scopes/main.py#L70
[global_state_java]: https://github.com/GoogleCloudPlatform/java-docs-samples/tree/main/functions/concepts/scopes
[global_state_nodejs]: https://github.com/GoogleCloudPlatform/nodejs-docs-samples/blob/main/functions/tips/scopeDemo/index.js#L33
[global_lazy_go]: https://github.com/GoogleCloudPlatform/golang-samples/blob/master/functions/tips/lazy.go
[global_lazy_nodejs]: https://github.com/GoogleCloudPlatform/nodejs-docs-samples/blob/main/functions/tips/scopeDemo/index.js#L55
[global_lazy_python]: https://github.com/GoogleCloudPlatform/python-docs-samples/blob/main/functions/tips-lazy-globals/main.py#L95
[global_lazy_java]: https://github.com/GoogleCloudPlatform/java-docs-samples/tree/main/functions/concepts/lazy-fields
[broken_go]: https://github.com/GoogleCloudPlatform/golang-samples/tree/main/run/hello-broken
[broken_nodejs]: https://github.com/GoogleCloudPlatform/nodejs-docs-samples/tree/main/run/hello-broken
[broken_java]: https://github.com/GoogleCloudPlatform/java-docs-samples/tree/main/run/hello-broken
[broken_python]: https://github.com/GoogleCloudPlatform/python-docs-samples/tree/main/run/hello-broken
[idp_sql_nodejs]: https://github.com/GoogleCloudPlatform/nodejs-docs-samples/tree/main/run/idp-sql
[idp_sql_python]: https://github.com/GoogleCloudPlatform/python-docs-samples/tree/main/run/idp-sql
[idp_sql_java]: https://github.com/GoogleCloudPlatform/java-docs-samples/tree/main/run/idp-sql
[grpc_go]: https://github.com/GoogleCloudPlatform/golang-samples/tree/main/run/grpc-ping
[markdown_preview_go]: https://github.com/GoogleCloudPlatform/golang-samples/tree/main/run/markdown-preview
[markdown_preview_python]: https://github.com/GoogleCloudPlatform/python-docs-samples/tree/main/run/markdown-preview
[markdown_preview_java]: https://github.com/GoogleCloudPlatform/java-docs-samples/tree/main/run/markdown-preview
[markdown_preview_nodejs]: https://github.com/GoogleCloudPlatform/nodejs-docs-samples/tree/main/run/markdown-preview
[vpc_sample]: vpc-sample
[gcloud_report]: gcloud-report
[multicontainer_hello_nginx_sample]: multi-container/hello-nginx-sample
[multicontainer_open_policy_agent_sample]: multi-container/open-policy-agent-sample
[idtoken_request_go]: https://github.com/GoogleCloudPlatform/golang-samples/blob/master/functions/security/idtoken.go
[idtoken_request_nodejs]: https://github.com/googleapis/google-auth-library-nodejs/blob/master/samples/idtokens-serverless.js
[idtoken_request_python]: https://github.com/GoogleCloudPlatform/python-docs-samples/blob/main/auth/service-to-service/auth.py
[idtoken_request_java]: https://github.com/GoogleCloudPlatform/java-docs-samples/tree/main/run/authentication

**Samples by Language**: [nodejs][nodejs], [golang][golang], [python][python], [java][java], [php][php], [ruby][ruby]

[nodejs]: https://github.com/GoogleCloudPlatform/nodejs-docs-samples/tree/main/run#readme
[golang]: https://github.com/GoogleCloudPlatform/golang-samples/tree/main/run#readme
[python]: https://github.com/GoogleCloudPlatform/python-docs-samples/tree/main/run#readme
[java]: https://github.com/GoogleCloudPlatform/java-docs-samples/tree/main/run#readme
[php]: https://github.com/GoogleCloudPlatform/php-docs-samples/tree/main/run#readme
[ruby]: https://github.com/GoogleCloudPlatform/ruby-docs-samples/tree/main/run#readme

## Deploy a sample with a button click!

The [Cloud Run Button](https://github.com/GoogleCloudPlatform/cloud-run-button)
makes your Cloud Run service deployable with the push of a button. (It will open a Cloud Shell window.)

|        Sample             |                         Cloud Run Button                        |        Details from the Cloud Run Documentation                 |
| ------------------------- | --------------------------------------------------------------- | --------------------------------------------------------------- |
| Hello World - Python      | [<img src="https://storage.googleapis.com/cloudrun/button.svg" alt="Run on Google Cloud" height="30">][run_button_hello_python] | [Quickstart: build and deploy][qs_guide] |
| Hello World - Java        | [<img src="https://storage.googleapis.com/cloudrun/button.svg" alt="Run on Google Cloud" height="30">][run_button_hello_java]   | [Quickstart: build and deploy][qs_guide] |
| Hello World - Node.js     | [<img src="https://storage.googleapis.com/cloudrun/button.svg" alt="Run on Google Cloud" height="30">][run_button_hello_nodejs]   | [Quickstart: build and deploy][qs_guide] |
| Hello World - Go          | [<img src="https://storage.googleapis.com/cloudrun/button.svg" alt="Run on Google Cloud" height="30">][run_button_hello_go]     | [Quickstart: build and deploy][qs_guide] |

[qs_guide]: https://cloud.google.com/run/docs/quickstarts#build-and-deploy-a-web-service
[run_button_hello_python]: https://deploy.cloud.run/?git_repo=https://github.com/GoogleCloudPlatform/python-docs-samples&dir=run/helloworld
[run_button_hello_java]: https://deploy.cloud.run/?git_repo=https://github.com/GoogleCloudPlatform/java-docs-samples&dir=run/helloworld
[run_button_hello_nodejs]: https://deploy.cloud.run/?git_repo=https://github.com/GoogleCloudPlatform/nodejs-docs-samples&dir=run/helloworld
[run_button_hello_go]: https://deploy.cloud.run/?git_repo=https://github.com/GoogleCloudPlatform/golang-samples&dir=run/helloworld

Find more samples to deploy with the Cloud Run Button by using the [Sample Index](#sample-index) above.

## Contributing changes

Entirely new samples are not accepted. Bug fixes are welcome, either as pull
requests or as GitHub issues.

See [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to contribute.

## Licensing

Code in this repository is licensed under the Apache 2.0. See [LICENSE](LICENSE).
