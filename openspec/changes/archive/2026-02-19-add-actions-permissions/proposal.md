# Change: Add GitHub Actions Permissions Configuration

Resolves: [#5](https://github.com/gjed/github-as-yaml/issues/5)

## Why

GitHub Actions permissions are security-critical settings that currently require manual configuration
outside of this template. Supply chain security depends on controlling which actions can run, what
permissions workflows have, and how fork pull requests are handled. Without centralized configuration,
organizations risk inconsistent security postures across repositories.

## What Changes

- Add `actions` configuration block to repository definitions in `repositories.yml`
- Add organization-level `actions` configuration in `config.yml`
- Support allowed actions policies: `all`, `local_only`, `selected`
- Support allowed action patterns for `selected` policy
- Configure default workflow permissions (`read` or `write`)
- Configure fork pull request workflow policies
- Handle subscription tier limitations (some features require paid plans)

## Impact

- Affected specs: `repository-management`
- Affected code:
  - `terraform/modules/repository/main.tf` (new resources)
  - `terraform/modules/repository/variables.tf` (new variables)
  - `terraform/yaml-config.tf` (configuration parsing)
  - `config/config.yml` (organization-level schema)
  - `config/repositories.yml` (repository-level schema)
- New Terraform resources:
  - `github_actions_repository_permissions`
  - `github_actions_organization_permissions` (optional, for org-level config)
- Backward compatible: existing configurations continue to work without actions settings
