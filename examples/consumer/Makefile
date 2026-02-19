.PHONY: help init plan apply validate fmt

help:
	@echo "Consumer GitHub org Terraform shortcuts"
	@echo ""
	@echo "  make init      Initialize Terraform (download providers & module)"
	@echo "  make plan      Preview changes"
	@echo "  make apply     Apply changes"
	@echo "  make validate  Validate configuration"
	@echo "  make fmt       Format Terraform files"
	@echo ""
	@echo "Set GITHUB_TOKEN before running plan/apply."

init:
	terraform init

plan:
	terraform plan -out=tfplan

apply:
	terraform apply tfplan && rm -f tfplan

validate:
	terraform validate

fmt:
	terraform fmt -recursive
