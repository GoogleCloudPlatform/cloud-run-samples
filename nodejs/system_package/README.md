# Cloud Run System Package sample

This sample shows how to use a CLI tool installed as a system package as part of a web service.

## Build

```
docker build --tag graphviz-web:nodejs .
```

## Run

```
docker run --rm -p 9090:8080 graphviz-web:nodejs
```

## Test

```
docker build --tag graphviz-web:nodejs .
docker build -f test.Dockerfile --tag graphviz-web-test:nodejs .
docker run --rm graphviz-web-test:nodejs npm test
```

To run tests as part of ongoing development without dependency changes:

```
docker run --rm -v $PWD:/usr/src/app graphviz-web-test:nodejs npm test
```

## Deploy

```
gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/graphivz-web
gcloud alpha run deploy graphviz-web --image gcr.io/${GOOGLE_CLOUD_PROJECT}/graphivz-web
```