# Ffreis MLflow

This repository builds the MLflow tracking and artifacts server container image. The Kubernetes deployment manifests live in the ffreis-infrastructure repo.

> **Warning**
> Do not store secrets or other sensitive data in git. Use Kubernetes Secrets or your cluster's secret manager.

## Container Image

The MLflow server container is built with:
- **Base**: python:3.12-slim
- **Dependency manager**: uv
- **Runtime user**: non-root (uid 2000)
- **Exposed port**: 8787

For dependencies and versions, see [container/mlflow/pyproject.toml](container/mlflow/pyproject.toml).

## Build

```
make build
```

This produces a single `mlflow` image used for both tracking and artifacts servers.

## Deploy

Kubernetes resources and manifests are in the ffreis-infrastructure repo:
```
cd ../ffreis-infrastructure/ffreis-mlflow
make apply
```

## Cleanup

Clean local images:
```
make clean-images
```

Clean Kubernetes resources (from ffreis-infrastructure):
```
cd ../ffreis-infrastructure/ffreis-mlflow
make clean-kube
```
