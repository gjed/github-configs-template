.PHONY: help init plan plan-repo plan-show plan-pr apply apply-repo destroy validate fmt clean

# Plan file location
PLAN_FILE := terraform/tfplan

# Default target
help:
	@echo "GitHub Organization Terraform Management"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  init       Initialize Terraform (download providers)"
	@echo "  plan       Preview changes and save plan to file"
	@echo "  plan-repo  Plan for a single repository (REPO=name)"
	@echo "  plan-show  Show saved plan in human-readable format"
	@echo "  plan-pr    Run plan and post comment to GitHub PR (CI)"
	@echo "  apply      Apply changes from saved plan"
	@echo "  apply-repo Apply changes for a single repository (REPO=name)"
	@echo "  destroy    Destroy all managed resources (use with caution)"
	@echo "  validate   Validate Terraform configuration"
	@echo "  fmt        Format Terraform files"
	@echo "  clean      Remove Terraform cache, state files, and plan"
	@echo ""
	@echo "Examples:"
	@echo "  make plan-repo REPO=my-repo-name"
	@echo "  make apply-repo REPO=my-repo-name"
	@echo ""
	@echo "Environment:"
	@echo "  GITHUB_TOKEN must be set (see .env.example)"

# Initialize Terraform
init:
	@echo "Initializing Terraform..."
	cd terraform && terraform init

# Plan changes and save to file
plan:
	@echo "Planning Terraform changes..."
	cd terraform && terraform plan -out=tfplan
	@echo ""
	@echo "Plan saved to $(PLAN_FILE)"
	@echo "Run 'make plan-show' to view the plan or 'make apply' to apply"

# Plan for a single repository
plan-repo:
	@if [ -z "$(REPO)" ]; then \
		echo "Error: REPO is required. Usage: make plan-repo REPO=repository-name"; \
		exit 1; \
	fi
	@echo "Planning changes for repository: $(REPO)..."
	cd terraform && terraform plan -target='module.repositories["$(REPO)"]' -out=tfplan
	@echo ""
	@echo "Plan saved to $(PLAN_FILE)"
	@echo "Run 'make plan-show' to view the plan or 'make apply' to apply"

# Show saved plan in human-readable format
plan-show:
	@if [ ! -f "$(PLAN_FILE)" ]; then \
		echo "Error: No plan file found. Run 'make plan' first."; \
		exit 1; \
	fi
	cd terraform && terraform show tfplan

# Run plan and post comment to GitHub PR (for CI)
# Requires: GITHUB_TOKEN, TFCMT_REPO_OWNER, TFCMT_REPO_NAME, TFCMT_PR_NUMBER
plan-pr:
	@echo "Running plan with tfcmt..."
	cd terraform && tfcmt plan -- terraform plan

# Apply changes from saved plan
apply:
	@if [ ! -f "$(PLAN_FILE)" ]; then \
		echo "Error: No plan file found. Run 'make plan' first."; \
		exit 1; \
	fi
	@echo "Applying Terraform changes from saved plan..."
	cd terraform && terraform apply tfplan
	@rm -f $(PLAN_FILE)
	@echo "Plan file removed after successful apply"

# Apply changes for a single repository (without requiring saved plan)
apply-repo:
	@if [ -z "$(REPO)" ]; then \
		echo "Error: REPO is required. Usage: make apply-repo REPO=repository-name"; \
		exit 1; \
	fi
	@echo "Applying changes for repository: $(REPO)..."
	cd terraform && terraform apply -target='module.repositories["$(REPO)"]'

# Destroy resources (with confirmation)
destroy:
	@echo "WARNING: This will destroy all managed resources!"
	cd terraform && terraform destroy

# Validate configuration
validate:
	@echo "Validating Terraform configuration..."
	cd terraform && terraform validate

# Format Terraform files
fmt:
	@echo "Formatting Terraform files..."
	cd terraform && terraform fmt -recursive

# Clean up
clean:
	@echo "Cleaning up Terraform cache and plan..."
	rm -rf terraform/.terraform
	rm -f terraform/.terraform.lock.hcl
	rm -f $(PLAN_FILE)
	@echo "Note: State files (*.tfstate) are preserved for safety"
