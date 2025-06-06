# OpenAPI Schema for SonarQube Server Web API v1

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
