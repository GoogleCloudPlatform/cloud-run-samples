# Test Cases for Linters

The files in this directory are for testing linting tools.

## YAML Files

* [test-yaml.yaml](./test-yaml.yaml):
    * Missing the license
    * Includes multiple syntax errors

## Dockerfiles

* [Dockerfile](./Dockerfile): Example hello world build

* [multistage.Dockerfile](./multistage.Dockerfile): Example multistage build

* [module.Dockerfile](./module.Dockerfile): References an unknown module

* [from.Dockerfile](./from.Dockerfile): Missing the `FROM` statement

* [shell.Dockerfile](./shell.Dockerfile):
    * Includes a bad shell script
    * Includes a specific file that can't be found
    * Includes bad shell syntax

* [syntax.Dockerfile](./syntax.Dockerfile):
    * Uses `ENTRYPOINT` instead of `CMD`
    * Uses `ADD` instead of `CMD`
    * Doesn't include a version tag for base image
    * `PORT` is set as an env var
    * Uses lower case instructions
    * Missing the license

## Shell Scripts

* [bad-script.sh](./bad-script.sh): Includes syntax issues

* [broken-script.sh](./broken-script.sh): Includes errors in script

## Markdown

* [test-markdown.md](./test-markdown.md):
    * Includes multiple syntax errors
