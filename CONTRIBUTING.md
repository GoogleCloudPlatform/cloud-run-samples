# Contributing

## Contributor License Agreements

We'd love to accept your sample apps and patches! Before we can take them, we
have to jump a couple of legal hurdles.

Please fill out either the individual or corporate Contributor License Agreement
(CLA).

* If you are an individual writing original source code and you're sure you own
  the intellectual property, then you'll need to sign an [individual
  CLA](https://developers.google.com/open-source/cla/individual).
* If you work for a company that wants to allow you to contribute your work,
  then you'll need to sign a [corporate
  CLA](https://developers.google.com/open-source/cla/corporate).

Follow either of the two links above to access the appropriate CLA and
instructions for how to sign and return it. Once we receive it, we'll be able to
accept your pull requests.

## Contributing a Patch

1. Submit an issue describing your proposed change.
1. The repo owner will respond to your issue promptly.
1. If your proposed change is accepted, and you haven't already done so, sign a
   Contributor License Agreement (see details above).
1. Fork the repo, develop, and test your code changes.
1. Ensure that your code adheres to the existing style in the sample to which
   you are contributing. Refer to the
   [Google Cloud Platform Samples Style Guide]
   (https://github.com/GoogleCloudPlatform/Template/wiki/style.html) for the
   recommended coding standards for this organization.
1. Ensure that your code has an appropriate set of unit tests which all pass.
1. Submit a pull request.

## Repository Layout

Sample apps should be in a top-level directory: /sample-app.

If the code has different instructions per platform, this should be explicitly noted in the README.

If the code is different per platform, a sub-directory should be used:

```
.
└── sample-app
    ├── managed
    └── anthos
```

Samples that demonstrate integrations with Events for Cloud Run should be prefixed with `events-`: `events-sample-app`.

The [`testing`](https://github.com/GoogleCloudPlatform/cloud-run-samples/tree/main/testing) directory contains resources for automated testing.

## New Samples

### Should the sample be in this repository?

* If the sample is going to appear on cloud.google.com or be used by developers following instructions on cloud.google.com, it can be hosted in this repository.
* Tutorial instructions should not be included in the sample: the README should be used to point to separately published tutorials, and only contain instructions where a more official location is not available.
* If the sample highlights specific coding language practices in the context of Cloud Run, it should be hosted in a language-specific repository where the language practices can be properly reviewed, maintained, and subject to automated testing. This repository focuses on Dockerfiles, YAML, Shell scripts, and "architectural" solutions.

| Language | Repository                                                 |
| -------- | ---------------------------------------------------------- |
| Node.js  | https://github.com/GoogleCloudPlatform/nodejs-docs-samples |
| Golang   | https://github.com/GoogleCloudPlatform/golang-samples      |
| Python   | https://github.com/GoogleCloudPlatform/python-docs-samples |
| Java     | https://github.com/GoogleCloudPlatform/java-docs-samples   |
| C#       | https://github.com/GoogleCloudPlatform/dotnet-docs-samples |
| PHP      | https://github.com/GoogleCloudPlatform/php-docs-samples    |
| Ruby     | https://github.com/GoogleCloudPlatform/ruby-docs-samples   |
| Kotlin   | https://github.com/GoogleCloudPlatform/kotlin-samples      |
| C++      | https://github.com/GoogleCloudPlatform/cpp-samples         |


### Maintenance

You may be asked to be the maintainer of a sample you contribute depending on it's intended use.
