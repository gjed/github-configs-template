# OSS Readiness

This capability ensures the project meets open source best practices for documentation, licensing, and
code quality tooling.

## ADDED Requirements

### Requirement: Project Documentation

The project SHALL provide a README.md file at the repository root that includes:

- Project name and brief description
- Prerequisites (Terraform version, GitHub provider, etc.)
- Quick start guide for first-time users
- Configuration reference for all supported options
- Usage examples demonstrating common patterns
- Troubleshooting section for common issues
- Links to related documentation

#### Scenario: New user discovers the project

- **WHEN** a user visits the repository
- **THEN** they see a README.md that explains the project purpose
- **AND** they can understand the prerequisites needed
- **AND** they can follow the quick start to get running

#### Scenario: User needs configuration reference

- **WHEN** a user wants to customize their configuration
- **THEN** they can find documentation for all supported YAML options
- **AND** they can see examples of each configuration option

### Requirement: Contribution Guidelines

The project SHALL provide a CONTRIBUTING.md file that documents:

- How to set up a development environment
- Code style and formatting expectations
- Pull request submission process
- Issue reporting guidelines
- Reference to the Code of Conduct

#### Scenario: New contributor wants to help

- **WHEN** a contributor wants to submit a change
- **THEN** they can find clear instructions in CONTRIBUTING.md
- **AND** they understand the expected PR workflow
- **AND** they know how to set up their development environment

#### Scenario: User wants to report an issue

- **WHEN** a user encounters a bug or has a feature request
- **THEN** they can find guidance on how to report issues
- **AND** they know what information to include

### Requirement: Code of Conduct

The project SHALL provide a CODE_OF_CONDUCT.md file based on the Contributor Covenant that establishes
community standards for respectful and inclusive participation.

#### Scenario: Community member checks expected behavior

- **WHEN** a community member wants to understand expected behavior
- **THEN** they can find a CODE_OF_CONDUCT.md file
- **AND** it clearly describes acceptable and unacceptable behavior
- **AND** it provides enforcement guidelines and contact information

### Requirement: Open Source License

The project SHALL include a LICENSE file at the repository root containing the Apache License 2.0 full
text.

#### Scenario: User checks license terms

- **WHEN** a user or organization evaluates the project for adoption
- **THEN** they can find a LICENSE file with clear terms
- **AND** the license is Apache 2.0 (permissive, business-friendly)

### Requirement: Pre-commit Hooks Configuration

The project SHALL provide a .pre-commit-config.yaml file that configures automated checks for:

- Terraform formatting (terraform fmt)
- Terraform validation (terraform validate)
- Terraform best practices (tflint)
- Terraform security scanning (checkov)
- Markdown linting (markdownlint)
- YAML linting (yamllint)
- General file hygiene (trailing whitespace, end-of-file newline)

#### Scenario: Developer runs pre-commit locally

- **WHEN** a developer runs `pre-commit run --all-files`
- **THEN** all configured hooks execute
- **AND** Terraform files are checked for formatting, validity, and security
- **AND** Markdown files are checked for style issues
- **AND** YAML files are checked for syntax and style
- **AND** files are checked for trailing whitespace and missing newlines

#### Scenario: Developer commits changes

- **WHEN** a developer makes a git commit (with pre-commit installed)
- **THEN** pre-commit hooks run automatically on staged files
- **AND** the commit is blocked if any hook fails

### Requirement: Markdown Lint Configuration

The project SHALL provide a .markdownlint.yaml configuration file that defines markdown style rules
appropriate for technical documentation.

#### Scenario: Markdownlint uses project configuration

- **WHEN** markdownlint runs on Markdown files
- **THEN** it uses the rules defined in .markdownlint.yaml
- **AND** the rules allow common technical documentation patterns (code blocks, long lines in tables)

### Requirement: YAML Lint Configuration

The project SHALL provide a .yamllint.yaml configuration file that defines YAML style rules appropriate
for Terraform configurations and CI/CD workflows.

#### Scenario: Yamllint uses project configuration

- **WHEN** yamllint runs on YAML files
- **THEN** it uses the rules defined in .yamllint.yaml
- **AND** the rules are appropriate for infrastructure configuration files
