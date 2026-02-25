# GitHub As YAML

Manage your GitHub organization's repositories as code using Terraform and YAML configuration.

<!-- markdownlint-disable MD033 -->
<p align="center">
  <img src="wiki/logo.png" alt="GitHub As YAML" width="400">
</p>
<!-- markdownlint-enable MD033 -->

> **Note:** See [gjed/github-configs-public](https://github.com/gjed/github-configs-public) for a public example of
> this project in action.

## ✨ Features

- **YAML-based configuration** - Human-readable repository definitions
- **Configuration groups** - Share settings across multiple repositories (DRY)
- **Repository rulesets** - Enforce branch protection and policies
- **GitHub Actions permissions** - Control which actions can run and workflow permissions
- **Webhook management** - Configure CI/CD and notification webhooks as code
- **Subscription-aware** - Gracefully handles GitHub Free tier limitations
- **Onboarding script** - Easily import existing repositories

## How It Works

```text
                                    ┌─────────────────────┐
                                    │       GitHub        │
                                    │                     │
┌─────────────────┐                 │  ┌──────────────┐   │
│ repositories.yml│                 │  │ tf-modules   │   │
│                 │                 │  └──────────────┘   │
│ - tf-modules    │    Terraform    │  ┌──────────────┐   │
│ - api-gateway   │ ──────────────> │  │ api-gateway  │   │
│ - docs-site     │                 │  └──────────────┘   │
│                 │                 │  ┌──────────────┐   │
└─────────────────┘                 │  │ docs-site    │   │
                                    │  └──────────────┘   │
                                    └─────────────────────┘
```

## 🚀 Quick Start

```bash
# 1. Use this template on GitHub, then clone your repository

# 2. Set your GitHub token
export GITHUB_TOKEN="your_github_token"

# 3. Configure and apply
make init && make plan && make apply
```

See the [Quick Start Guide](https://github.com/gjed/github-as-yaml/wiki/Quick-Start) for detailed setup instructions.

## 🔧 Example Configuration

```yaml
# config/repositories.yml
terraform-modules:
  description: "Shared Terraform modules"
  groups: ["base", "oss"]
  topics: ["terraform"]

api-gateway:
  description: "Internal API gateway"
  groups: ["base", "internal"]

docs-site:
  description: "Documentation website"
  groups: ["base", "oss"]
  homepage_url: "https://docs.example.com"
  webhooks:
    - slack-notify        # Reference webhook from config/webhook/
```

## 📚 Documentation

Documentation is available in the [Wiki](https://github.com/gjed/github-as-yaml/wiki):

- [Quick Start Guide](https://github.com/gjed/github-as-yaml/wiki/Quick-Start) - Get up and running
- [Configuration Reference](https://github.com/gjed/github-as-yaml/wiki/Configuration-Reference) -
  All available options
- [Using as a Module](https://github.com/gjed/github-as-yaml/wiki/Using-as-a-Module) -
  Reusable module setup and migration guide
- [Customization Guide](https://github.com/gjed/github-as-yaml/wiki/Customization) - Extend the template
- [Examples](https://github.com/gjed/github-as-yaml/wiki/Examples) - Common configuration patterns
- [Troubleshooting](https://github.com/gjed/github-as-yaml/wiki/Troubleshooting) - Common issues and solutions

> **Note:** The wiki is available as a git submodule in the `wiki/` directory for local access.

## 📋 Requirements

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- GitHub Personal Access Token with `repo` and `admin:org` scopes

## ⚡ Commands

```bash
make init      # Initialize Terraform
make plan      # Preview changes
make apply     # Apply changes
make validate  # Validate configuration
```

## 💳 GitHub Subscription Tiers

| Feature | Free | Pro | Team | Enterprise |
| ------- | ---- | --- | ---- | ---------- |
| Public repo rulesets | Yes | Yes | Yes | Yes |
| Private repo rulesets | No | Yes | Yes | Yes |
| Push rulesets | No | No | Yes | Yes |
| Actions permissions | Yes | Yes | Yes | Yes |

Unsupported features are automatically skipped based on your subscription tier.

## 🔒 GitHub Actions Security Best Practices

GitHub Actions permissions can significantly impact your supply chain security. This template supports
comprehensive Actions configuration at both organization and repository levels.

### Configuration Options

**Organization Level** (`config/config.yml`):

```yaml
actions:
  enabled_repositories: all         # all, none, selected
  allowed_actions: selected         # all, local_only, selected
  allowed_actions_config:
    github_owned_allowed: true      # Allow github/* actions
    verified_allowed: true          # Allow verified marketplace actions
    patterns_allowed:
      - "actions/*"
      - "your-org/*"
  default_workflow_permissions: read  # read, write
  can_approve_pull_request_reviews: false
```

**Repository Level** (`config/repositories.yml` or `config/groups.yml`):

```yaml
my-repo:
  actions:
    enabled: true
    allowed_actions: selected
    allowed_actions_config:
      github_owned_allowed: true
      verified_allowed: true
      patterns_allowed:
        - "actions/*"
```

### Security Recommendations

1. **Use `selected` allowed_actions** - Restrict which actions can run to reduce supply chain risk
2. **Default to `read` workflow permissions** - Only grant write access when explicitly needed
3. **Disable PR approval for workflows** - Prevent automated bypassing of review requirements
4. **Use group inheritance** - Define secure defaults in groups that repositories inherit
5. **Pin action versions** - Use SHA or version tags in `patterns_allowed` (e.g., `actions/checkout@v4`)

## Using as a Module

The `terraform/` directory is a reusable module. Point to it from any org's config
repo instead of forking:

```hcl
module "github_org" {
  source      = "github.com/gjed/github-as-yaml//terraform?ref=v1.0.0"
  config_path = "${path.root}/config"
}
```

See the [Using as a Module](https://github.com/gjed/github-as-yaml/wiki/Using-as-a-Module)
wiki page for the full setup guide, variable and output reference, remote state
configuration, script usage, and migration instructions for existing forks.

## ⚖️ License

[Apache 2.0](LICENSE)
