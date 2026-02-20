.DEFAULT_GOAL = help
.PHONY = help
help:
	@echo "Commands:"
	@echo "- build\t\t\t\t: build mlflow server image"
	@echo "- clean-images\t\t\t: prune local images (destructive)"

.PHONY = build
build:
	docker build -f ./container/mlflow/Dockerfile -t mlflow ./container/mlflow

.PHONY = clean-images
clean-images:
	docker image prune -a -f
