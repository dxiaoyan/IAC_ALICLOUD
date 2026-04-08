# Makefile for IacService package build

.PHONY: help check-profile replace-placeholders prepare-package build-package clean

help:
	@echo "Usage: make <target> PROFILE=<profile>"
	@echo ""
	@echo "Targets:"
	@echo "  replace-placeholders  Replace {{PROFILE.xxx}} placeholders in tfdeploy.yaml"
	@echo "  prepare-package       Merge deployments/<profile> into stacks/"
	@echo "  build-package         Build code-<profile>.zip package"
	@echo "  clean                 Remove build artifacts"

check-profile:
	@if [ -z "$(PROFILE)" ]; then \
		echo "Error: PROFILE is required"; \
		echo "Usage: make <target> PROFILE=<profile>"; \
		exit 1; \
	fi

replace-placeholders: check-profile
	@PROFILE_FILE="deployments/$(PROFILE)/profile.yaml"; \
	if [ ! -f "$$PROFILE_FILE" ]; then \
		echo "Error: $$PROFILE_FILE not found"; \
		exit 1; \
	fi; \
	YQ_CMD="$(CURDIR)/scripts/yq"; \
	for file in $$(find deployments/$(PROFILE) -name "tfdeploy.yaml" -type f); do \
		for key in $$($$YQ_CMD 'keys | .[]' $$PROFILE_FILE 2>/dev/null); do \
			if [ -n "$$key" ]; then \
				value=$$($$YQ_CMD ".$$key" $$PROFILE_FILE 2>/dev/null | tr -d '"'); \
				if [ -n "$$value" ]; then \
					placeholder="{{PROFILE.$$key}}"; \
					sed -i.bak "s|$$placeholder|$$value|g" "$$file"; \
				fi; \
			fi; \
		done; \
	done; \
	find deployments -name "*.bak" -type f -delete >/dev/null 2>&1 || true

prepare-package: replace-placeholders
	@rm -rf .build/$(PROFILE)
	@mkdir -p .build/$(PROFILE)
	@cp -rp modules scripts stacks deployments .build/$(PROFILE)/
	@cp -p Makefile .build/$(PROFILE)/Makefile
	@if [ -d ".build/$(PROFILE)/deployments/$(PROFILE)" ]; then \
		cp -rp .build/$(PROFILE)/deployments/$(PROFILE)/* .build/$(PROFILE)/stacks/; \
	fi
	@rm -rf .build/$(PROFILE)/deployments

build-package: prepare-package
	@cd .build/$(PROFILE) && \
		zip -q -r -X ../../code-$(PROFILE).zip . -x "*.git*" "*.terraform*" "*.zip" "*.bak"
	@echo "Package created: code-$(PROFILE).zip"

clean:
	@rm -rf .build
	@rm -f code-*.zip execution_result_*.md

