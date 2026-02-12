MODULE ?=

# Optional overrides
TRIVY_FLAGS ?= --scanners misconfig

MODULES ?= $(filter-out .github,$(shell ls -d */ 2>/dev/null | sed 's:/$::'))

.PHONY: help \
	terraform-fmt terraform-init terraform-validate \
	tflint-init tflint \
	trivy \
	check \
	check-module-var check-all

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
	@echo "Batch:"
	@echo "  make check-all                           # Run checks for all modules (top-level dirs except .github/)"

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

check-all:
	@echo "Running checks for modules: $(MODULES)"
	@for m in $(MODULES); do \
		echo ""; \
		echo "=== Running checks for $$m ==="; \
		$(MAKE) check MODULE=$$m || exit $$?; \
	done
