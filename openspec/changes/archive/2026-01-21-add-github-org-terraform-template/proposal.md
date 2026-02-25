# Change: Add GitHub Organization Terraform Template

## Why

Organizations managing multiple GitHub repositories need a standardized, maintainable way to configure
repositories at scale. Currently, repository settings are managed manually through the GitHub UI,
leading to inconsistent configurations, security drift, and operational overhead. A public template that
implements a factory pattern for GitHub organization management via Terraform would enable teams to:

- Manage all repository configurations as code (IaC)
- Apply consistent security policies and settings across repositories
- Enable GitOps workflows for infrastructure changes
- Reduce manual configuration errors

## What Changes

This is a new project (greenfield) that creates a public GitHub template repository. The template
implements:

- **Terraform module** for managing GitHub repositories with a factory pattern
- **YAML-based configuration** for repositories, groups, and rulesets
- **Configuration groups** to share settings across multiple repositories
- **Repository rulesets** for branch protection and policy enforcement
- **Documentation** for setup, usage, and customization
- **Example configurations** demonstrating common patterns

> **Note:** CI/CD workflow deferred to future spec - users can implement their own GitHub Actions based on their requirements.

The design is inspired by `gjed/github-configs` and adapted for public use.

## Impact

- **Affected specs**: Creates new `repository-management` capability
- **Affected code**: New project - creates entire file structure
- **Dependencies**: Terraform >= 1.0, GitHub Provider ~> 6.0
- **Target users**: Organizations/individuals managing multiple GitHub repositories
