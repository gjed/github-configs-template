# Tasks: Add GitHub Actions Permissions Configuration

## 1. Repository Module Updates

- [x] 1.1 Add `actions` variable to `terraform/modules/repository/variables.tf`
- [x] 1.2 Add `github_actions_repository_permissions` resource to `terraform/modules/repository/main.tf`
- [x] 1.3 Add conditional logic to skip resource when `actions` is not configured

## 2. YAML Configuration Parsing

- [x] 2.1 Update `terraform/yaml-config.tf` to parse `actions` block from repository configs
- [x] 2.2 Implement merge logic for `actions` configuration from groups
- [x] 2.3 Implement list merging for `patterns_allowed` field
- [x] 2.4 Apply secure defaults for unspecified `actions` fields

## 3. Organization-Level Configuration

- [x] 3.1 Add organization `actions` parsing to `terraform/yaml-config.tf`
- [x] 3.2 Create `github_actions_organization_permissions` resource in `terraform/main.tf`
- [x] 3.3 Add conditional logic to skip resource when org `actions` is not configured

## 4. Configuration Schema Documentation

- [x] 4.1 Update `config/config.yml` with organization-level `actions` schema example
- [x] 4.2 Update `config/repositories.yml` with repository-level `actions` example
- [x] 4.3 Update `config/groups.yml` with `actions` inheritance example

## 5. Validation and Testing

- [x] 5.1 Run `terraform validate` to verify syntax
- [x] 5.2 Run `terraform plan` with example configurations
- [x] 5.3 Test configuration inheritance from groups
- [x] 5.4 Test secure defaults are applied correctly
- [x] 5.5 Verify backward compatibility with existing configs (no `actions` block)

## 6. Documentation

- [x] 6.1 Add security best practices section to README
- [x] 6.2 Document subscription tier limitations for Actions features
- [x] 6.3 Add example secure configurations

## Dependencies

- Tasks 1.x must complete before 5.x (module must exist before testing)
- Tasks 2.x must complete before 5.3 and 5.4 (merge logic needed for inheritance tests)
- Tasks 3.x can run in parallel with 1.x and 2.x
- Tasks 4.x can run in parallel with 1.x, 2.x, and 3.x
- Tasks 6.x should run after 5.x (document verified behavior)
