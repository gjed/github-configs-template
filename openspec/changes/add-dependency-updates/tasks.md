## 1. Schema and Variables

- [x] 1.1 Add `dependabot` variable to `terraform/modules/repository/variables.tf`
- [x] 1.2 Add `renovate` variable to `terraform/modules/repository/variables.tf`
- [x] 1.3 Add `renovate_file_path` variable with default `renovate.json`

## 2. File Generation Resources

- [x] 2.1 Add `github_repository_file` resource for Dependabot in `main.tf`
- [x] 2.2 Add `github_repository_file` resource for Renovate in `main.tf`
- [x] 2.3 Add conditional logic to only create files when config is provided

## 3. Configuration Merging

- [x] 3.1 Add Dependabot merge logic to `terraform/yaml-config.tf`
- [x] 3.2 Add Renovate merge logic to `terraform/yaml-config.tf`
- [x] 3.3 Handle `updates` list merging by ecosystem+directory key for Dependabot
- [x] 3.4 Handle `packageRules` list concatenation for Renovate
- [x] 3.5 Handle `extends` list merging and deduplication for Renovate

## 4. Module Integration

- [x] 4.1 Pass merged Dependabot config from yaml-config.tf to repository module
- [x] 4.2 Pass merged Renovate config from yaml-config.tf to repository module
- [x] 4.3 Update `terraform/main.tf` module calls to include new variables

## 5. Example Configurations

- [x] 5.1 Add example Dependabot group configuration to `config/groups.yml`
- [x] 5.2 Add example Renovate group configuration to `config/groups.yml`
- [x] 5.3 Add example repository with Dependabot override
- [x] 5.4 Add example repository with Renovate override

## 6. Testing and Validation

- [x] 6.1 Run `terraform validate` to verify syntax
- [x] 6.2 Run `terraform plan` with example configurations
- [x] 6.3 Verify generated Dependabot YAML is valid format
- [x] 6.4 Verify generated Renovate JSON is valid format

## 7. Documentation

- [x] 7.1 Document Dependabot configuration options in README
- [x] 7.2 Document Renovate configuration options in README
- [x] 7.3 Add migration notes for existing manual configs
