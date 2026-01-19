# 🏗️ GitHub Organization Terraform Template

Manage your GitHub organization's repositories as code using Terraform and YAML configuration.

<!-- markdownlint-disable MD033 -->
<p align="center">
  <img src="docs/logo.png" alt="GitHub Organization Terraform Template" width="400">
</p>
<!-- markdownlint-enable MD033 -->

## ✨ Features

- **YAML-based configuration** - Human-readable repository definitions
- **Configuration groups** - Share settings across multiple repositories (DRY)
- **Repository rulesets** - Enforce branch protection and policies
- **Subscription-aware** - Gracefully handles GitHub Free tier limitations
- **Onboarding script** - Easily import existing repositories

## How It Works

```text
                                    ┌─────────────────────┐
                                    │         GitHub      │
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

See the [Quick Start Guide](docs/QUICKSTART.md) for detailed setup instructions.

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
```

## 📚 Documentation

- [Quick Start Guide](docs/QUICKSTART.md) - Get up and running
- [Configuration Reference](docs/CONFIGURATION.md) - All available options
- [Customization Guide](docs/CUSTOMIZATION.md) - Extend the template

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

The template automatically skips unsupported features based on your subscription tier.

## ⚖️ License

[Apache 2.0](LICENSE)
