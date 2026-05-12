.DEFAULT_GOAL = help

GITLEAKS         ?= gitleaks
LEFTHOOK_VERSION ?= 1.7.10
LEFTHOOK_DIR     ?= $(CURDIR)/.bin
LEFTHOOK_BIN     ?= $(LEFTHOOK_DIR)/lefthook

.PHONY = help build clean-images fmt lint test validate plan
help:
	@echo "Commands:"
	@echo "- build              : build mlflow server image"
	@echo "- clean-images       : prune local images (destructive)"
	@echo "- fmt                : not applicable (Docker-only repo)"
	@echo "- lint               : not applicable (Docker-only repo)"
	@echo "- test               : not applicable (Docker-only repo)"
	@echo "- validate           : not applicable (Docker-only repo)"
	@echo "- plan               : not applicable (Docker-only repo)"
	@echo "- secrets-scan-staged: scan staged diff for secrets"
	@echo "- lefthook-bootstrap : download lefthook binary into ./.bin"
	@echo "- lefthook-install   : install git hooks"
	@echo "- lefthook-run       : run all hooks locally"
	@echo "- lefthook           : install hooks and run them"

.PHONY = build
build:
	docker build -f ./container/mlflow/Containerfile -t mlflow ./container/mlflow

.PHONY = clean-images
clean-images:
	docker image prune -a -f

fmt:
	@echo "INFO: No source code to format in this Docker-only repo."

lint:
	@echo "INFO: No source code to lint in this Docker-only repo."

test:
	@echo "INFO: No automated tests in this Docker-only repo. To verify: make build"

validate:
	@echo "INFO: No source code to validate in this Docker-only repo."

plan:
	@echo "INFO: 'plan' is Terraform-specific and does not apply to this repo."

.PHONY = secrets-scan-staged
secrets-scan-staged:
	@command -v $(GITLEAKS) >/dev/null 2>&1 || (echo "Missing tool: $(GITLEAKS). Install: https://github.com/gitleaks/gitleaks#installing" && exit 1)
	$(GITLEAKS) protect --staged --redact

.PHONY = lefthook-bootstrap

PLATFORM_STANDARDS_SHA := b6a9ef92199954e3da5b80814321cb92f649fb81
PLATFORM_STANDARDS_RAW := https://raw.githubusercontent.com/FelipeFuhr/ffreis-platform-standards

HOOK_SCRIPTS := \
	check_merge_markers.sh \
	check_large_files.sh \
	check_binary_files.sh \
	check_commit_msg.sh \
	check_required_tools.sh

hook-scripts: ## Download bootstrap + hook scripts from ffreis-platform-standards
	@mkdir -p scripts/hooks
	@curl -fsSL "$(PLATFORM_STANDARDS_RAW)/$(PLATFORM_STANDARDS_SHA)/lefthook/bootstrap_lefthook.sh" \
		-o scripts/bootstrap_lefthook.sh && chmod +x scripts/bootstrap_lefthook.sh
	@for script in $(HOOK_SCRIPTS); do \
		curl -fsSL "$(PLATFORM_STANDARDS_RAW)/$(PLATFORM_STANDARDS_SHA)/lefthook/scripts/$$script" \
			-o "scripts/hooks/$$script" && chmod +x "scripts/hooks/$$script"; \
	done
	@echo "Hook scripts downloaded."

lefthook-bootstrap: hook-scripts
	LEFTHOOK_VERSION="$(LEFTHOOK_VERSION)" BIN_DIR="$(LEFTHOOK_DIR)" bash ./scripts/bootstrap_lefthook.sh

.PHONY = lefthook-install
lefthook-install: lefthook-bootstrap
	@if [ -x "$(LEFTHOOK_BIN)" ] && [ -x ".git/hooks/pre-commit" ] && [ -x ".git/hooks/pre-push" ] && [ -x ".git/hooks/commit-msg" ]; then \
		echo "lefthook hooks already installed"; \
		exit 0; \
	fi
	LEFTHOOK="$(LEFTHOOK_BIN)" "$(LEFTHOOK_BIN)" install

.PHONY = lefthook-run
lefthook-run: lefthook-bootstrap
	LEFTHOOK="$(LEFTHOOK_BIN)" "$(LEFTHOOK_BIN)" run pre-commit
	@tmp_msg="$$(mktemp)"; \
	echo "chore(hooks): validate commit-msg hook" > "$$tmp_msg"; \
	LEFTHOOK="$(LEFTHOOK_BIN)" "$(LEFTHOOK_BIN)" run commit-msg -- "$$tmp_msg"; \
	rm -f "$$tmp_msg"

.PHONY = lefthook
lefthook: lefthook-bootstrap lefthook-install lefthook-run
