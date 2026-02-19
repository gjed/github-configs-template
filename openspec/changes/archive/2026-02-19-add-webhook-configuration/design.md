# Design: Add Webhook Configuration Support

## Context

This change adds webhook management to the repository factory. Webhooks contain sensitive secrets that require
secure handling. The design must balance usability with security while maintaining consistency with existing
configuration patterns.

## Goals

- Enable webhook configuration via YAML with same inheritance model as teams/topics
- Securely handle webhook secrets without exposing them in config files or state
- Support common webhook use cases (CI/CD, notifications, integrations)

## Non-Goals

- Organization-level webhooks (separate scope)
- Webhook delivery monitoring or retry logic (GitHub's responsibility)
- Secret rotation automation (out of scope)

## Decisions

### Decision 1: Webhook Definitions in `config/webhook/` Directory

Webhooks are defined centrally in `config/webhook/` and referenced by name in groups/repositories. This
follows the split config pattern established by the `add-split-config-files` change for rulesets.

```text
config/
├── webhook/
│   ├── ci.yml           # jenkins-ci, github-actions webhooks
│   └── notifications.yml # slack-notify, discord-notify webhooks
├── group/
│   └── with-ci.yml      # references: webhooks: [jenkins-ci]
└── repository/
    └── my-repo.yml      # references: webhooks: [slack-notify]
```

This pattern:

- Keeps webhook definitions DRY (define once, use many times)
- Follows existing patterns for rulesets
- Enables webhook reuse across many repositories
- Supports inline definitions for one-off webhooks

**Alternatives considered:**

- Inline-only definitions: Rejected because it leads to duplication across repositories

### Decision 2: Webhook Identification by Name

Webhooks will be identified by a user-provided name (the YAML key in `config/webhook/`). This enables:

- Meaningful merge behavior (repo webhook with same name overrides group webhook)
- Readable configuration and Terraform state
- Consistent pattern with rulesets (identified by name)

**Alternatives considered:**

- URL as identifier: Rejected because URLs may contain secrets or query params, and don't support override
  semantics

### Decision 3: Environment Variable Secret Pattern

Webhook secrets will use the `env:VAR_NAME` pattern to reference environment variables:

```yaml
webhooks:
  - name: ci-webhook
    secret: env:CI_WEBHOOK_SECRET
```

This pattern:

- Keeps secrets out of YAML config files
- Keeps secrets out of Git history
- Allows different secrets per environment (dev/staging/prod)
- Is explicit about secret source (no magic)

**Implementation:**

- Terraform will use `sensitive = true` for the secret variable
- Environment variable lookup happens at plan/apply time
- Missing environment variable results in Terraform error

**Alternatives considered:**

- Vault/secrets manager integration: Too complex for initial implementation, can be added later
- Direct secret in YAML: Security risk, rejected
- Terraform variables file: Would still require secure storage, adds complexity

### Decision 4: Webhook Merging Strategy

Webhooks merge by name, similar to teams:

1. Collect webhooks from all groups (in order)
1. Merge with repo-specific webhooks
1. Later definitions with same name override earlier ones
1. Webhooks with unique names are all included

This allows:

- Group-level common webhooks (e.g., security scanning)
- Repository-specific webhooks (e.g., project-specific CI)
- Override group webhooks when needed

### Decision 5: Default Values

| Field          | Default | Rationale                                           |
| -------------- | ------- | --------------------------------------------------- |
| `content_type` | `json`  | Most modern webhooks expect JSON                    |
| `active`       | `true`  | Webhooks should be active when defined              |
| `insecure_ssl` | `false` | SSL verification should be on by default (security) |

## Risks and Mitigations

### Risk: Secrets in Terraform State

Webhook secrets will appear in Terraform state even with `sensitive = true`.

**Mitigation:**

- Document that remote state backend with encryption is required for production
- This is consistent with existing guidance in `project.md`

### Risk: Webhook URL Validation

Invalid webhook URLs won't be caught until GitHub API call.

**Mitigation:**

- Rely on Terraform plan/apply feedback
- URL validation is complex (internal URLs, custom ports) and best left to GitHub

## Open Questions

None - design is straightforward following existing patterns.
