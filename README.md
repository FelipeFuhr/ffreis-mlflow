# Ffreis MLflow

This repository builds the MLflow tracking and artifacts server container image. Kubernetes deployment manifests live in a private infrastructure repository.

> **Warning**
> Do not store secrets or other sensitive data in git. Use Kubernetes Secrets or your cluster's secret manager.

## Container Image

The MLflow server container is built with:
- **Base**: python:3.12-slim
- **Dependency manager**: uv
- **Runtime user**: non-root (uid 2000)
- **Exposed port**: 8787

For dependencies and versions, see [container/mlflow/pyproject.toml](container/mlflow/pyproject.toml).
The lockfile used for reproducible builds is [container/mlflow/uv.lock](container/mlflow/uv.lock).

## Build

```
make build
```

This produces a single `mlflow` image used for both tracking and artifacts servers.

## CI

GitHub Actions includes:
- `docker-build`: verifies the MLflow image builds on PRs/pushes.
- `lock-sync`: checks `container/mlflow/uv.lock` is in sync with `pyproject.toml`.
- `trivy`: scans the built image for HIGH/CRITICAL vulnerabilities and uploads SARIF.

## Deploy

Kubernetes resources and manifests are in a private infrastructure repository. See that repo's README for deployment instructions.

## Cleanup

Clean local images:
```
make clean-images
```

To clean Kubernetes resources, see the private infrastructure repository.
