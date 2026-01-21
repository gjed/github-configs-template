## 1. Implementation

- [ ] 1.1 Create helper local to load and merge YAML files from a directory
- [ ] 1.2 Update `repos_config` local to load from `config/repository/` directory
- [ ] 1.3 Update `groups_config` local to load from `config/group/` directory
- [ ] 1.4 Update `rulesets_config` local to load from `config/ruleset/` directory
- [ ] 1.5 Add validation to fail if required directories are missing

## 2. Migration

- [ ] 2.1 Create `config/repository/` directory with split config files
- [ ] 2.2 Create `config/group/` directory with split config files
- [ ] 2.3 Create `config/ruleset/` directory with split config files
- [ ] 2.4 Remove old single-file configs (`repositories.yml`, `groups.yml`, `rulesets.yml`)

## 3. Documentation

- [ ] 3.1 Update `docs/CONFIGURATION.md` with mandatory directory structure
- [ ] 3.2 Add example directory structure in `docs/examples.md`

## 4. Validation

- [ ] 4.1 Test with directory-based configuration for repositories
- [ ] 4.2 Test with directory-based configuration for groups
- [ ] 4.3 Test with directory-based configuration for rulesets
- [ ] 4.4 Test error handling when directory is missing
- [ ] 4.5 Run `terraform validate` and `terraform plan`
