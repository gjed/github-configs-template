# Change: Extract project into a reusable, publishable Terraform module

## Why

Using this project for a new GitHub org currently requires forking or copying the entire repository,
which duplicates Terraform logic that belongs to the infrastructure layer rather than the consumer.
Extracting the Terraform code into a standalone, publishable module lets any org adopt the YAML-driven
config pattern by writing only a minimal `main.tf` and their own config files.

## What Changes

- **BREAKING**: Remove the `provider "github"` block from the module root — consumers must configure
  their own provider.
- **BREAKING**: Replace all hardcoded `config/` paths in `yaml-config.tf` with `var.config_path`, which
  consumers set to `"${path.root}/config"`.
- Add `config_path` input variable to `variables.tf`.
- Add `variables.tf` and `outputs.tf` to surface the module interface cleanly.
- Update `onboard-repos.sh` and `offboard-repos.sh` to handle the nested module state path
  (`module.github_org.module.repositories["<repo>"]`) used by consumers.
- Ship `validate-config.py` and `.pre-commit-config.yaml` as a consumer scaffold (separate from the
  module itself — not inside the TF module directory).
- Create an example consumer directory (or companion template repo) showing the minimal setup (~15 lines
  of `main.tf`).
- Add a published-module `README.md` documenting the interface, variables, and consumer example.
- Tag an initial release (`v1.0.0`) after the refactor is complete.

## Impact

- Affected specs: `repository-management`, new capability `module-interface`, new capability
  `consumer-template`
- Affected code: `terraform/main.tf`, `terraform/yaml-config.tf`, `terraform/variables.tf`,
  `terraform/outputs.tf`, `scripts/onboard-repos.sh`, `scripts/offboard-repos.sh`, `README.md`
- Downstream: Any fork of this repo used as a direct Terraform root will need to add their own provider
  block and set `config_path` (migration path documented in design.md).
