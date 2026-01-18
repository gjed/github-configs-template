# Change: Add OSS Preparation

## Why

This repository is intended to be a public template that others can fork and use. Before publishing as
open source, it needs standard OSS documentation and tooling to:

- Help users understand what the project does and how to use it (README)
- Set clear contribution expectations and guidelines (CONTRIBUTING)
- Establish community standards (CODE_OF_CONDUCT)
- Define legal terms for usage and distribution (LICENSE)
- Ensure code quality and consistency via automated linting (pre-commit hooks)

Without these, the project will be difficult to adopt and maintain as a community project.

## What Changes

- **README.md**: Comprehensive documentation including purpose, prerequisites, quick start, configuration
  reference, examples, and troubleshooting
- **CONTRIBUTING.md**: Guidelines for contributing including development setup, code style, PR process,
  and issue reporting
- **CODE_OF_CONDUCT.md**: Contributor Covenant code of conduct for community standards
- **LICENSE**: Apache 2.0 license (permissive, business-friendly, common for IaC projects)
- **.pre-commit-config.yaml**: Pre-commit hooks configuration for:
  - Terraform linting (`terraform fmt`, `terraform validate`, `tflint`)
  - Terraform security scanning (`checkov`)
  - Markdown linting (`markdownlint`)
  - YAML linting (`yamllint`)
  - General file hygiene (trailing whitespace, end-of-file newline)

## Impact

- **Affected specs**: Creates new `oss-readiness` capability
- **Affected code**: Adds new files at project root
- **Dependencies**:
  - pre-commit framework
  - tflint (Terraform linter)
  - checkov (Terraform security scanner)
  - markdownlint-cli (Markdown linter)
  - yamllint (YAML linter)
- **Target users**: Contributors, maintainers, and users adopting the template
