# Change: Add Split Configuration File Support

## Why

As organizations grow, managing many repositories, groups, and rulesets in single YAML files becomes
unwieldy. Users need the flexibility to organize configurations into separate files within directories
for better maintainability and team ownership.

## What Changes

- Split configuration MUST be loaded from `<type>/` directories containing multiple `.yml` files
- Applies to: `repository`, `group`, and `ruleset` configuration types only
- `config/config.yml` remains a single file (organization-level settings, not splittable)
- All `.yml` files within supported directories are loaded and merged alphabetically
- Single-file configuration (`<type>.yml`) is NOT supported for splittable types - directory structure is mandatory
- Directory names use singular form (like modernized apt sources.list.d)

## Directory Structure

```text
config/
  config.yml              # Single file (organization settings) - NOT splittable
  repository/             # Split directory (mandatory)
    frontend.yml
    backend.yml
  group/                  # Split directory (mandatory)
    oss.yml
    internal.yml
  ruleset/                # Split directory (mandatory)
    branch-protection.yml
```

## Impact

- Affected specs: `repository-management`
- Affected code: `terraform/yaml-config.tf` (config loading logic)
- Breaking change: existing single-file configurations must be migrated to directories
