# OpenAPI Schema for SonarQube Server Web API v1

## Versions

* [v9.9](https://github.com/9506hqwy/openapi-spec-sonarqube-v1/blob/v9.9/openapi.yml)
* [v25.6](https://github.com/9506hqwy/openapi-spec-sonarqube-v1/blob/main/openapi.yml)

## Generating

Download web service definitions and response examples from SonarQube server.

```sh
./gen/dump_response_examples.sh
```

Convert response examples to OpenAPI response schema.

```sh
./gen/response_example_to_schema.sh
```

Generate OpenAPI schema.

```sh
./gen/webservices_to_openapi.sh > ./components/openapi.yml
```

Bundle one file.

```sh
redocly bundle -d --remove-unused-components -o openapi.yml ./components/openapi.yml
```

Verify OpenAPI schema format.

```sh
redocly lint openapi.yml
```

Preview documents.

```sh
redocly preview-docs openapi.yml
```
