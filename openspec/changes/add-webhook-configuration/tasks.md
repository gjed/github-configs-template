# Tasks: Add Webhook Configuration Support

## 1. Schema and Variables

- [x] 1.1 Add `webhooks` variable to `terraform/modules/repository/variables.tf`
- [x] 1.2 Define webhook object type with url, content_type, secret, events, active, insecure_ssl fields

## 2. Repository Module Implementation

- [x] 2.1 Add `github_repository_webhook` resource to `terraform/modules/repository/main.tf`
- [x] 2.2 Implement environment variable lookup for webhook secrets
- [x] 2.3 Add webhook outputs to `terraform/modules/repository/outputs.tf`

## 3. Webhook Definitions Loading

- [x] 3.1 Add logic to load webhook definitions from `config/webhook/` directory
- [x] 3.2 Merge webhook definition files alphabetically
- [x] 3.3 Handle missing `config/webhook/` directory gracefully (empty map)

## 4. Configuration Merging

- [x] 4.1 Add webhook reference resolution logic to `terraform/yaml-config.tf`
- [x] 4.2 Support both reference-by-name and inline webhook definitions
- [x] 4.3 Implement group webhook merging (later groups override by name)
- [x] 4.4 Implement repository webhook merging (repo overrides group by name)
- [x] 4.5 Add validation for undefined webhook references
- [x] 4.6 Pass merged webhooks to repository module

## 5. Example Configuration

- [x] 5.1 Create `config/webhook/` directory with example files (commented out)
- [x] 5.2 Add example webhook references to group configuration (commented out)
- [x] 5.3 Add example webhook references to repository configuration (commented out)

## 6. Documentation

- [x] 6.1 Update README with webhook configuration examples
- [x] 6.2 Document supported GitHub events
- [x] 6.3 Document secret handling pattern (`env:VAR_NAME`)
- [x] 6.4 Document webhook definition vs reference pattern

## 7. Validation

- [x] 7.1 Run `terraform validate` to verify syntax
- [x] 7.2 Run `terraform plan` to verify resource creation
- [x] 7.3 Test webhook inheritance from groups
- [x] 7.4 Test repository-level webhook overrides
- [x] 7.5 Test undefined webhook reference error handling
