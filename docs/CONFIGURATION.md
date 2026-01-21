# Configuration Reference

Complete reference for all configuration options.

## File Structure

Configuration uses a **mandatory directory structure** for repositories, groups, and rulesets. Each
directory can contain multiple `.yml` files that are loaded and merged alphabetically.

```text
config/
├── config.yml              # Organization and global settings (single file)
├── repository/             # Repository definitions (directory - mandatory)
│   ├── default-repositories.yml
│   ├── frontend.yml
│   └── backend.yml
├── group/                  # Configuration groups (directory - mandatory)
│   ├── default-groups.yml
│   └── custom-groups.yml
├── ruleset/                # Ruleset definitions (directory - mandatory)
│   ├── default-rulesets.yml
│   └── custom-rulesets.yml
└── webhook/                # Webhook definitions (directory - optional)
    └── *.yml               # Webhook definition files
```

### Directory Loading Behavior

- All `.yml` files within each directory are loaded and merged alphabetically
- Later files (alphabetically) override earlier ones for duplicate keys
- Empty directories result in empty configuration maps
- **Missing directories will cause Terraform to fail** with an error

### Important: Shallow Merge Warning

When the same key (e.g., repository name, group name, or ruleset name) appears in multiple files,
**the entire definition is replaced, not merged**. This is a shallow merge behavior.

**Example of problematic configuration:**

```yaml
# config/repository/a-frontend.yml
my-repo:
  description: "My repository"
  visibility: public
  topics:
    - frontend
```

```yaml
# config/repository/b-backend.yml
my-repo:
  description: "Updated description"
  has_wiki: true
```

**Result:** `my-repo` will only have `description` and `has_wiki` from `b-backend.yml`.
The `visibility` and `topics` from `a-frontend.yml` are **completely lost**.

**Best practice:** Define each repository, group, or ruleset in only one file. Use file organization
for logical grouping (e.g., by team or project), not for splitting a single entity's configuration.

## config.yml

Organization-level settings.

```yaml
# Required: GitHub organization or username
organization: your-org-name

# Required: GitHub subscription tier
# Options: free, pro, team, enterprise
subscription: free

# Optional: Default settings (fallback values)
defaults:
  visibility: private
  has_wiki: false
  has_issues: false
  # ... (see Repository Settings below)
```

## config/group/ Directory

Named configuration groups that repositories can inherit from. Each `.yml` file in this directory
defines one or more groups.

```yaml
# config/group/oss.yml
oss:
  # All repository settings (see below)
  visibility: public
  has_issues: true

  # Topics are merged across groups
  topics:
    - topic1

  # Teams are merged (later groups override)
  teams:
    team-slug: permission

  # Rulesets are merged across groups
  rulesets:
    - ruleset-name
```

### Merge Behavior

When a repository uses multiple groups:

| Setting Type | Behavior |
| ------------ | -------- |
| Single values | Later groups override |
| `topics` | Merged and deduplicated |
| `teams` | Merged, later overrides |
| `collaborators` | Merged, later overrides |
| `rulesets` | Merged and deduplicated |
| `webhooks` | Merged, later overrides by name |

Example:

```yaml
# config/group/base.yml
base:
  topics: ["managed"]
  teams:
    devops: admin
```

```yaml
# config/group/oss.yml
oss:
  topics: ["open-source"]
  teams:
    community: push
```

```yaml
# config/repository/my-repo.yml
my-repo:
  groups: ["base", "oss"]
  # Results in:
  # topics: ["managed", "open-source"]
  # teams: {devops: admin, community: push}
```

## config/repository/ Directory

Individual repository definitions. Each `.yml` file in this directory defines one or more repositories.

```yaml
# config/repository/frontend.yml
repository-name:
  # Required
  description: "Repository description"
  groups: ["group1", "group2"]

  # Optional: Override any setting from groups
  visibility: public
  has_wiki: true

  # Optional: Additional topics (merged with groups)
  topics:
    - extra-topic

  # Optional: Additional teams (merged with groups)
  teams:
    team-slug: permission

  # Optional: Additional rulesets
  rulesets:
    - custom-ruleset
```

## Repository Settings

All available repository settings:

| Setting | Type | Default | Description |
| ------- | ---- | ------- | ----------- |
| `visibility` | string | `private` | `public`, `private`, or `internal` |
| `has_wiki` | bool | `false` | Enable wiki |
| `has_issues` | bool | `false` | Enable issues |
| `has_projects` | bool | `false` | Enable projects |
| `has_discussions` | bool | `false` | Enable discussions |
| `allow_merge_commit` | bool | `true` | Allow merge commits |
| `allow_squash_merge` | bool | `true` | Allow squash merges |
| `allow_rebase_merge` | bool | `true` | Allow rebase merges |
| `allow_auto_merge` | bool | `false` | Enable auto-merge |
| `allow_update_branch` | bool | `false` | Suggest updating PR branches |
| `delete_branch_on_merge` | bool | `false` | Auto-delete head branches |
| `web_commit_signoff_required` | bool | `false` | Require signoff on web commits |
| `vulnerability_alerts` | bool | `true` | Enable security alerts for vulnerable dependencies |
| `homepage_url` | string | `null` | Project homepage URL |
| `license_template` | string | `null` | License template (e.g., `mit`, `apache-2.0`) |
| `topics` | list | `[]` | Repository topics |
| `teams` | map | `{}` | Team permissions |
| `collaborators` | map | `{}` | Collaborator permissions |
| `rulesets` | list | `[]` | Ruleset names to apply |
| `webhooks` | list | `[]` | Webhook names or inline definitions |

## config/ruleset/ Directory

Reusable ruleset definitions. Each `.yml` file in this directory defines one or more rulesets.

```yaml
# config/ruleset/branch-protection.yml
ruleset-name:
  target: branch        # branch or tag
  enforcement: active   # active, evaluate, or disabled

  conditions:
    ref_name:
      include:
        - "~DEFAULT_BRANCH"  # Special: default branch
        - "refs/heads/main"
        - "refs/heads/release/*"
      exclude:
        - "refs/heads/dev/*"

  # Optional: Bypass actors
  bypass_actors:
    - actor_id: 12345
      actor_type: Team      # Team, OrganizationAdmin, RepositoryRole
      bypass_mode: always   # always or pull_request

  rules:
    - type: deletion
    - type: non_fast_forward
    - type: required_linear_history
    - type: required_signatures
    - type: pull_request
      parameters:
        required_approving_review_count: 1
        dismiss_stale_reviews_on_push: true
        require_code_owner_review: false
        require_last_push_approval: false
        required_review_thread_resolution: false
```

### Ruleset Templates

Templates provide reusable ruleset configurations that can be referenced by name in repository or group
configurations. Templates and default rulesets are defined in `config/ruleset/default-rulesets.yml`.

#### Default Templates

Two template rulesets are provided:

**strict-main** - Strict protection for main branch:

- 2 required approving reviews
- Code owner review required
- Required linear history
- Targets default branch

**relaxed-devel** - Lighter protection for devel branch:

- 1 required approving review
- Targets `devel` branch only

#### Default Rulesets

The following pre-configured rulesets are available for direct use:

**oss-main-protection** - Basic OSS main branch protection:

- 1 required approving review
- Required linear history
- No bypass actors
- Targets default branch

**oss-main-bypass** - OSS main with maintainer bypass:

- 1 required approving review
- Maintainers and admins can bypass
- Suitable for OSS projects requiring flexibility
- Targets default branch

**internal-main-protection** - Internal repository protection:

- Prevents deletion and force pushes
- Required linear history
- No pull request requirements
- Requires paid GitHub plan for private repos
- Targets default branch

**tag-protection** - Version tag protection:

- Prevents deletion and updates
- Targets `v*` tags (e.g., v1.0.0, v2.1.3)

#### Using Templates

Reference templates in repository or group configurations:

```yaml
# config/repository/my-repo.yml
my-app:
  description: "My Application"
  groups: []
  rulesets:
    - template: strict-main        # Use template as-is
    - template: relaxed-devel      # Use another template
    - my-custom-ruleset            # Mix with direct ruleset references
```

#### Template Overrides

You can override template settings by providing the complete configuration sections. Note that overrides
replace the entire section from the template (e.g., providing `rules` replaces all rules):

```yaml
# config/repository/critical-app.yml
critical-service:
  description: "Critical Service"
  groups: []
  rulesets:
    - template: strict-main
      # Override to require 3 approvals instead of 2
      # Note: Must include all rules you want, as this replaces the template's rules
      rules:
        - type: deletion
        - type: non_fast_forward
        - type: required_linear_history
        - type: pull_request
          parameters:
            required_approving_review_count: 3  # Changed from 2
            dismiss_stale_reviews_on_push: true
            require_code_owner_review: true
            require_last_push_approval: false
```

You can also override other template fields like `enforcement`, `target`, or `conditions`:

```yaml
rulesets:
  - template: strict-main
    enforcement: disabled  # Override enforcement level
    conditions:            # Override branch targeting
      ref_name:
        include:
          - "refs/heads/main"
          - "refs/heads/production"
```

#### Creating Custom Templates

Add your own templates to `config/ruleset/default-rulesets.yml`:

```yaml
# config/ruleset/default-rulesets.yml
my-custom-template:
  target: branch
  enforcement: active
  conditions:
    ref_name:
      include:
        - "refs/heads/feature/*"
  rules:
    - type: pull_request
      parameters:
        required_approving_review_count: 1

strict-main:
  # ... existing templates ...
```

### Available Rule Types

| Rule Type | Description | Has Parameters |
| --------- | ----------- | -------------- |
| `deletion` | Prevent deletion | No |
| `non_fast_forward` | Prevent force push | No |
| `required_linear_history` | Require linear history | No |
| `required_signatures` | Require signed commits | No |
| `creation` | Control creation | No |
| `update` | Control updates | No |
| `pull_request` | Require PR reviews | Yes |
| `required_status_checks` | Require CI checks | Yes |
| `required_deployments` | Require deployments | Yes |
| `branch_name_pattern` | Branch naming rules | Yes |
| `commit_message_pattern` | Commit message rules | Yes |
| `commit_author_email_pattern` | Author email rules | Yes |
| `committer_email_pattern` | Committer email rules | Yes |

### Pull Request Parameters

```yaml
- type: pull_request
  parameters:
    required_approving_review_count: 1
    dismiss_stale_reviews_on_push: false
    require_code_owner_review: false
    require_last_push_approval: false
    required_review_thread_resolution: false
```

### Status Checks Parameters

```yaml
- type: required_status_checks
  parameters:
    strict_required_status_checks_policy: false
    required_checks:
      - context: "ci/build"
        integration_id: 12345  # Optional
```

### Pattern Parameters

```yaml
- type: commit_message_pattern
  parameters:
    operator: regex  # starts_with, ends_with, contains, regex
    pattern: "^(feat|fix|docs):"
    name: "Conventional Commits"
    negate: false
```

## config/webhook/

Webhook definitions directory. Define webhooks here and reference them by name in groups or repositories.

### Webhook Definition

```yaml
# config/webhook/ci.yml
jenkins-ci:
  url: https://jenkins.example.com/github-webhook/
  content_type: json         # Optional: json (default) or form
  secret: env:JENKINS_SECRET # Optional: Secret from webhook_secrets variable
  events:                    # Required: GitHub events to trigger
    - push
    - pull_request
  active: true               # Optional: Enable webhook (default: true)
  insecure_ssl: false        # Optional: Skip SSL verification (default: false)

slack-notify:
  url: https://hooks.slack.com/services/YOUR/WEBHOOK/URL
  events:
    - push
    - release
```

### Webhook Settings

| Setting | Type | Default | Description |
| ------- | ---- | ------- | ----------- |
| `url` | string | **required** | Webhook endpoint URL |
| `content_type` | string | `json` | Payload format: `json` or `form` |
| `secret` | string | `null` | Webhook secret (`env:VAR_NAME` format) |
| `events` | list | **required** | GitHub events to trigger webhook |
| `active` | bool | `true` | Enable/disable webhook |
| `insecure_ssl` | bool | `false` | Skip SSL certificate verification |

### Common GitHub Events

| Event | Triggered when |
| ----- | -------------- |
| `push` | Commits pushed to branch |
| `pull_request` | PR opened, closed, synchronized |
| `release` | Release published, created |
| `issues` | Issue opened, edited, closed |
| `issue_comment` | Comment on issue or PR |
| `create` | Branch or tag created |
| `delete` | Branch or tag deleted |
| `deployment` | Deployment created |
| `deployment_status` | Deployment status changed |
| `workflow_run` | GitHub Actions workflow run |

See [GitHub Webhooks Documentation](https://docs.github.com/en/webhooks/webhook-events-and-payloads) for all events.

### Webhook Secrets

Webhook secrets use the `env:VAR_NAME` pattern to reference the `webhook_secrets` Terraform variable:

```yaml
# config/webhook/ci.yml
jenkins-ci:
  url: https://jenkins.example.com/webhook
  secret: env:JENKINS_WEBHOOK_SECRET # pragma: allowlist secret
  events: [push]
```

Pass secrets via Terraform:

```bash
# Using command line
terraform apply -var='webhook_secrets={"JENKINS_WEBHOOK_SECRET":"your-secret-value"}' # pragma: allowlist secret

# Using environment variable
export TF_VAR_webhook_secrets='{"JENKINS_WEBHOOK_SECRET":"your-secret-value"}' # pragma: allowlist secret
terraform apply

# Using tfvars file (keep secure!)
# terraform.tfvars
webhook_secrets = { # pragma: allowlist secret
  JENKINS_WEBHOOK_SECRET = "your-secret-value" # pragma: allowlist secret
}
```

### Using Webhooks

Reference webhooks by name in groups or repositories:

```yaml
# config/group/with-ci.yml
with-ci:
  webhooks:
    - jenkins-ci          # Reference by name
    - slack-notify

# config/repository/my-repo.yml
my-repo:
  groups: ["base", "with-ci"]
  webhooks:
    - discord-notify      # Additional webhook
    - name: custom        # Inline definition
      url: https://custom.example.com/hook
      events: [release]
```

### Webhook Merge Behavior

- Groups are applied in order; later groups override earlier by webhook name
- Repository webhooks override group webhooks by name
- Webhooks with unique names are all included

Example:

```yaml
# groups.yml
base:
  webhooks:
    - ci-webhook          # URL: https://ci-v1.example.com

modern:
  webhooks:
    - ci-webhook          # URL: https://ci-v2.example.com (overrides base)

# repositories.yml
my-repo:
  groups: ["base", "modern"]
  # Result: ci-webhook uses https://ci-v2.example.com
```

## Team Permissions

| Permission | Description |
| ---------- | ----------- |
| `pull` | Read access |
| `triage` | Read + manage issues/PRs |
| `push` | Read + write |
| `maintain` | Push + manage (no admin) |
| `admin` | Full access |

## Examples

### Open Source Project

```yaml
# config/repository/awesome-library.yml
awesome-library:
  description: "An awesome open source library"
  groups: ["base", "oss"]
  license_template: mit
  topics:
    - library
    - awesome
```

### Internal Tool with Custom Settings

```yaml
# config/repository/internal-tool.yml
internal-tool:
  description: "Internal automation tool"
  groups: ["base", "internal"]
  has_wiki: false          # Override: disable wiki
  has_discussions: true    # Override: enable discussions
  teams:
    platform: admin        # Additional team
```

### Repository with Multiple Rulesets

```yaml
# config/repository/critical-service.yml
critical-service:
  description: "Critical production service"
  groups: ["base", "internal"]
  rulesets:
    - internal-main-protection
    - release-branch-protection
    - tag-protection
```
