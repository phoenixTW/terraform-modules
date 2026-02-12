MODULE ?=

# Optional overrides
TRIVY_FLAGS ?= --scanners misconfig

.PHONY: help \
	terraform-fmt terraform-init terraform-validate \
	tflint-init tflint \
	trivy \
	check \
	check-module-var \
	check-bastion_host check-common_vpc

help:
	@echo "Terraform modules Makefile"
	@echo
	@echo "Usage:"
	@echo "  make check MODULE=<module_dir>           # Run fmt, init, validate, tflint, trivy for a module"
	@echo "  make terraform-fmt MODULE=<module_dir>   # Run terraform fmt -check -recursive"
	@echo "  make terraform-init MODULE=<module_dir>  # Run terraform init -backend=false"
	@echo "  make terraform-validate MODULE=<module_dir>  # Run terraform validate"
	@echo "  make tflint-init MODULE=<module_dir>     # Run tflint --init"
	@echo "  make tflint MODULE=<module_dir>          # Run tflint"
	@echo "  make trivy MODULE=<module_dir>           # Run trivy fs misconfig scan"
	@echo
	@echo "Shortcuts:"
	@echo "  make check-bastion_host                  # Run checks for bastion_host/"
	@echo "  make check-common_vpc                    # Run checks for common_vpc/"

check-module-var:
	@if [ -z "$(MODULE)" ]; then \
		echo "Error: MODULE variable is required (e.g. 'make check MODULE=bastion_host')."; \
		exit 1; \
	fi

check: terraform-fmt terraform-init terraform-validate tflint-init tflint trivy

terraform-fmt: check-module-var
	@echo "Running terraform fmt for $(MODULE)..."
	terraform -chdir=$(MODULE) fmt -check -recursive

terraform-init: check-module-var
	@echo "Running terraform init (backend disabled) for $(MODULE)..."
	terraform -chdir=$(MODULE) init -backend=false

terraform-validate: check-module-var
	@echo "Running terraform validate for $(MODULE)..."
	terraform -chdir=$(MODULE) validate

tflint-init: check-module-var
	@echo "Running tflint --init for $(MODULE)..."
	cd "$(MODULE)" && tflint --init

tflint: check-module-var
	@echo "Running tflint for $(MODULE)..."
	cd "$(MODULE)" && tflint

trivy: check-module-var
	@echo "Running trivy misconfig scan for $(MODULE)..."
	trivy fs $(TRIVY_FLAGS) "$(MODULE)"

# Convenience targets for current modules
check-bastion_host:
	@$(MAKE) check MODULE=bastion_host

check-common_vpc:
	@$(MAKE) check MODULE=common_vpc

