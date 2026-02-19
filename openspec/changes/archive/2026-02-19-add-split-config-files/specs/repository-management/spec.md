## MODIFIED Requirements

### Requirement: YAML-Based Repository Configuration

The system SHALL read repository configurations from YAML files in the `config/` directory using
Terraform's native `yamldecode()` function.

Split configuration applies to: `repository`, `group`, and `ruleset` types only. These MUST be defined
in directories using singular naming convention: `config/repository/`, `config/group/`, `config/ruleset/`.

Organization-level settings (`config/config.yml`) remain a single file and do not support splitting.

#### Scenario: Load common configuration

- **WHEN** Terraform is initialized and planned
- **THEN** the system reads `config/config.yml` as a single file
- **AND** parses organization name and subscription tier

#### Scenario: Load repository configuration from directory

- **GIVEN** a `config/repository/` directory exists with files `frontend.yml` and `backend.yml`
- **WHEN** Terraform is initialized and planned
- **THEN** the system reads all `.yml` files from the `config/repository/` directory
- **AND** merges them alphabetically into a single configuration map

#### Scenario: Invalid YAML syntax

- **WHEN** a configuration file contains invalid YAML syntax
- **THEN** Terraform fails with a parsing error message indicating the file and location

#### Scenario: Load group configuration from directory

- **GIVEN** a `config/group/` directory exists with files `oss.yml` and `internal.yml`
- **WHEN** Terraform is initialized and planned
- **THEN** the system reads all `.yml` files from the `config/group/` directory
- **AND** merges them alphabetically into a single groups configuration map

#### Scenario: Load ruleset configuration from directory

- **GIVEN** a `config/ruleset/` directory exists with files `branch-protection.yml` and `tag-rules.yml`
- **WHEN** Terraform is initialized and planned
- **THEN** the system reads all `.yml` files from the `config/ruleset/` directory
- **AND** merges them alphabetically into a single rulesets configuration map

#### Scenario: Empty directory fallback

- **GIVEN** a `config/repository/` directory exists but contains no `.yml` files
- **WHEN** Terraform is initialized and planned
- **THEN** the system uses an empty configuration map for repositories

#### Scenario: Duplicate keys across files in directory

- **GIVEN** a `config/repository/` directory contains `frontend.yml` with key `my-repo`
- **AND** `backend.yml` also contains key `my-repo`
- **WHEN** Terraform is initialized and planned
- **THEN** the later file (alphabetically, `frontend.yml`) overrides the earlier one (`backend.yml`)

#### Scenario: Missing directory

- **GIVEN** a `config/repository/` directory does not exist
- **WHEN** Terraform is initialized and planned
- **THEN** Terraform fails with an error indicating the required directory is missing

#### Scenario: Single file not supported for splittable types

- **GIVEN** only `config/repositories.yml` file exists (no `config/repository/` directory)
- **WHEN** Terraform is initialized and planned
- **THEN** Terraform fails with an error indicating directory structure is required
