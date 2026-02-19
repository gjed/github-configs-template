# repository-management Specification Delta

## ADDED Requirements

### Requirement: Webhook Definitions

The system SHALL support webhook definitions in the `config/webhook/` directory. Each webhook is defined
by name and can be referenced in groups or repositories.

#### Scenario: Load webhook definitions from directory

- **GIVEN** a `config/webhook/` directory exists with files `ci.yml` and `notifications.yml`
- **WHEN** Terraform is initialized and planned
- **THEN** the system reads all `.yml` files from the `config/webhook/` directory
- **AND** merges them alphabetically into a single webhooks definition map

#### Scenario: Webhook definition structure

- **GIVEN** a webhook is defined in `config/webhook/ci.yml`:
  ```yaml
  jenkins-ci:
    url: https://jenkins.example.com/github-webhook/
    content_type: json
    secret: env:JENKINS_WEBHOOK_SECRET
    events:
      - push
      - pull_request
    active: true
  ```
- **WHEN** Terraform parses the configuration
- **THEN** the webhook is available to reference by name `jenkins-ci`

#### Scenario: Empty webhook directory

- **GIVEN** a `config/webhook/` directory exists but contains no `.yml` files
- **WHEN** Terraform is initialized and planned
- **THEN** the system uses an empty webhook definitions map

#### Scenario: Missing webhook directory

- **GIVEN** a `config/webhook/` directory does not exist
- **WHEN** Terraform is initialized and planned
- **THEN** the system uses an empty webhook definitions map
- **AND** no error is raised (webhooks are optional)

______________________________________________________________________

### Requirement: Webhook Configuration

The system SHALL support repository webhook configuration by referencing webhook names defined in
`config/webhook/` or by inline definition. Webhooks can be assigned at the group or repository level.

#### Scenario: Reference webhook by name in repository

- **GIVEN** a webhook `jenkins-ci` is defined in `config/webhook/ci.yml`
- **AND** a repository references webhooks in `config/repository/my-repo.yml`:
  ```yaml
  my-repo:
    webhooks:
      - jenkins-ci
  ```
- **WHEN** `terraform apply` is executed
- **THEN** the `jenkins-ci` webhook is created on the repository

#### Scenario: Inline webhook definition in repository

- **GIVEN** a repository defines an inline webhook in `config/repository/my-repo.yml`:
  ```yaml
  my-repo:
    webhooks:
      - name: custom-webhook
        url: https://custom.example.com/webhook
        events: [push]
  ```
- **WHEN** `terraform apply` is executed
- **THEN** the webhook is created on the repository with the specified URL and events

#### Scenario: Webhook with all options

- **GIVEN** a webhook is defined with all configuration options:
  ```yaml
  webhooks:
    - name: full-webhook
      url: https://example.com/hook
      content_type: json
      secret: env:WEBHOOK_SECRET
      events: [push, pull_request, release]
      active: true
      insecure_ssl: false
  ```
- **WHEN** `terraform apply` is executed
- **THEN** the webhook is created with content type `application/json`
- **AND** the secret is read from the `WEBHOOK_SECRET` environment variable
- **AND** the webhook triggers on push, pull_request, and release events
- **AND** the webhook is active
- **AND** SSL verification is enabled

#### Scenario: Webhook default values

- **GIVEN** a webhook is defined with only required fields:
  ```yaml
  webhooks:
    - name: minimal-webhook
      url: https://example.com/hook
      events: [push]
  ```
- **WHEN** `terraform apply` is executed
- **THEN** the webhook uses `content_type: json` by default
- **AND** the webhook is active by default
- **AND** SSL verification is enabled by default

______________________________________________________________________

### Requirement: Webhook Inheritance from Groups

The system SHALL support webhook inheritance from configuration groups with merge-by-name semantics.

#### Scenario: Reference webhook by name in group

- **GIVEN** a webhook `ci-pipeline` is defined in `config/webhook/ci.yml`
- **AND** group `with-ci` references webhooks in `config/group/with-ci.yml`:
  ```yaml
  with-ci:
    webhooks:
      - ci-pipeline
  ```
- **AND** a repository uses group `with-ci`
- **WHEN** `terraform apply` is executed
- **THEN** the `ci-pipeline` webhook is created on the repository

#### Scenario: Inline webhook definition in group

- **GIVEN** group `with-ci` defines an inline webhook:
  ```yaml
  with-ci:
    webhooks:
      - name: ci-pipeline
        url: https://ci.example.com/webhook
        events: [push, pull_request]
  ```
- **AND** a repository uses group `with-ci`
- **WHEN** `terraform apply` is executed
- **THEN** the `ci-pipeline` webhook is created on the repository

#### Scenario: Repository webhook overrides group webhook

- **GIVEN** group `with-ci` references webhook `ci-pipeline`
- **AND** the repository also references or defines a webhook named `ci-pipeline` with different settings
- **WHEN** the configuration is merged
- **THEN** the repository's webhook definition completely overrides the group's webhook

#### Scenario: Combine group and repository webhooks

- **GIVEN** group `with-ci` references webhook `ci-pipeline`
- **AND** the repository references webhook `slack-notify`
- **WHEN** the configuration is merged
- **THEN** both `ci-pipeline` and `slack-notify` webhooks are created on the repository

#### Scenario: Multiple groups with webhooks

- **GIVEN** group `with-ci` references webhook `ci-pipeline`
- **AND** group `with-notifications` references webhook `slack-notify`
- **AND** a repository uses groups `["with-ci", "with-notifications"]`
- **WHEN** the configuration is merged
- **THEN** both webhooks are created on the repository

#### Scenario: Later group overrides earlier group webhook

- **GIVEN** group `base` references webhook `ci-pipeline` with URL `https://old-ci.example.com`
- **AND** group `modern` references webhook `ci-pipeline` with URL `https://new-ci.example.com`
- **AND** a repository uses groups `["base", "modern"]`
- **WHEN** the configuration is merged
- **THEN** the `ci-pipeline` webhook uses URL `https://new-ci.example.com`

#### Scenario: Reference undefined webhook

- **GIVEN** a repository references webhook `undefined-webhook`
- **AND** no webhook named `undefined-webhook` is defined in `config/webhook/`
- **WHEN** `terraform plan` is executed
- **THEN** Terraform fails with an error indicating the webhook is not defined

______________________________________________________________________

### Requirement: Webhook Secret Handling

The system SHALL securely handle webhook secrets through environment variable references.

#### Scenario: Secret from environment variable

- **GIVEN** a webhook defines `secret: env:MY_WEBHOOK_SECRET`
- **AND** environment variable `MY_WEBHOOK_SECRET` is set to `supersecret123`
- **WHEN** `terraform apply` is executed
- **THEN** the webhook is created with secret `supersecret123`
- **AND** the secret is marked as sensitive in Terraform

#### Scenario: Missing environment variable

- **GIVEN** a webhook defines `secret: env:MISSING_VAR`
- **AND** environment variable `MISSING_VAR` is not set
- **WHEN** `terraform plan` is executed
- **THEN** Terraform fails with an error indicating the missing environment variable

#### Scenario: Webhook without secret

- **GIVEN** a webhook is defined without a `secret` field
- **WHEN** `terraform apply` is executed
- **THEN** the webhook is created without a secret
