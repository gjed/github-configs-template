# Customization Guide

How to extend and customize the template for your needs.

## Adding New Repository Settings

To add a new repository setting:

### 1. Add to module variables

Edit `terraform/modules/repository/variables.tf`:

```hcl
variable "new_setting" {
  description = "Description of new setting"
  type        = bool
  default     = false
}
```

### 2. Use in module resource

Edit `terraform/modules/repository/main.tf`:

```hcl
resource "github_repository" "this" {
  # ... existing settings
  new_setting = var.new_setting
}
```

### 3. Pass from main module

Edit `terraform/main.tf`:

```hcl
module "repositories" {
  # ... existing variables
  new_setting = each.value.new_setting
}
```

### 4. Add to yaml-config.tf

Edit `terraform/yaml-config.tf` in the `repositories` local:

```hcl
repositories = {
  for repo_name, repo_config in local.repos_yaml : repo_name => {
    # ... existing settings
    new_setting = lookup(repo_config, "new_setting",
      lookup(local.merged_configs[repo_name], "new_setting", false))
  }
}
```

### 5. Use in YAML

```yaml
# config/groups.yml
oss:
  new_setting: true

# config/repositories.yml
my-repo:
  new_setting: true
```

## Adding New Resources

### Example: Branch Default

To manage default branch settings:

1. Create new resource in module:

```hcl
# terraform/modules/repository/main.tf
resource "github_branch_default" "this" {
  count      = var.default_branch != null ? 1 : 0
  repository = github_repository.this.name
  branch     = var.default_branch
}
```

1. Add variable:

```hcl
# terraform/modules/repository/variables.tf
variable "default_branch" {
  description = "Default branch name"
  type        = string
  default     = null
}
```

1. Wire through main.tf and yaml-config.tf

## Creating Custom Groups

Design groups based on your organization's needs:

```yaml
# config/groups.yml

# Team-specific groups
frontend:
  topics:
    - frontend
    - react
  teams:
    frontend-team: push

backend:
  topics:
    - backend
    - api
  teams:
    backend-team: push

# Environment groups
production:
  rulesets:
    - strict-main-protection
    - tag-protection

staging:
  rulesets:
    - basic-main-protection

# Compliance groups
sox-compliant:
  web_commit_signoff_required: true
  rulesets:
    - audit-trail-protection
    - require-2-approvers
```

Then compose:

```yaml
# config/repositories.yml
payment-service:
  description: "Payment processing service"
  groups: ["base", "backend", "production", "sox-compliant"]
```

## Remote State Backend

For team collaboration, configure remote state:

### AWS S3

```hcl
# terraform/main.tf
terraform {
  backend "s3" {
    bucket         = "your-terraform-state"
    key            = "github-org/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

### Terraform Cloud

```hcl
# terraform/main.tf
terraform {
  cloud {
    organization = "your-org"
    workspaces {
      name = "github-configs"
    }
  }
}
```

### Google Cloud Storage

```hcl
# terraform/main.tf
terraform {
  backend "gcs" {
    bucket = "your-terraform-state"
    prefix = "github-org"
  }
}
```

## Importing Existing Repositories

Use the `scripts/onboard-repos.sh` script to import existing repositories:

```bash
# List all repos in your organization
./scripts/onboard-repos.sh --list

# Filter repos by name pattern
./scripts/onboard-repos.sh --list --filter "api-"

# Generate YAML entries for specific repos
./scripts/onboard-repos.sh --generate-yaml repo1 repo2 repo3

# Import repos into Terraform state (after adding to repositories.yml)
./scripts/onboard-repos.sh --import repo1 repo2

# Full onboarding: generate YAML and import in one command
./scripts/onboard-repos.sh --generate-yaml --import repo1 repo2

# Specify groups for generated YAML
./scripts/onboard-repos.sh --generate-yaml --groups "base,oss" repo1

# Dry run to see what would happen
./scripts/onboard-repos.sh --dry-run --import repo1 repo2
```

### Manual Import

For manual imports or troubleshooting:

```bash
# Import a single repository
cd terraform
terraform import \
  'module.repositories["repo-name"].github_repository.this' \
  org-name/repo-name

# Import team association
terraform import \
  'module.repositories["repo-name"].github_team_repository.this["team-slug"]' \
  repo-id:team-id
```

## Multiple Organizations

To manage multiple organizations:

### Option 1: Separate workspaces

```bash
# Create workspace per org
terraform workspace new org1
terraform workspace new org2

# Switch and apply
terraform workspace select org1
terraform apply -var-file=org1.tfvars
```

### Option 2: Separate directories

```text
organizations/
├── org1/
│   ├── config/
│   └── terraform/
└── org2/
    ├── config/
    └── terraform/
```

## Adding Validation

### YAML Schema Validation

Create a JSON schema for your YAML files:

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "patternProperties": {
    "^[a-z0-9-]+$": {
      "type": "object",
      "required": ["description", "groups"],
      "properties": {
        "description": { "type": "string" },
        "groups": {
          "type": "array",
          "items": { "type": "string" }
        }
      }
    }
  }
}
```

### Custom Validation Script

Extend `scripts/validate-config.py`:

```python
def validate_team_references(config):
    """Ensure all referenced teams exist."""
    defined_teams = set(config.get('teams', {}).keys())
    for repo in config.get('repositories', {}).values():
        for team in repo.get('teams', {}).keys():
            if team not in defined_teams:
                raise ValueError(f"Unknown team: {team}")
```

## CI/CD Customization

### Add Manual Approval

```yaml
# .github/workflows/terraform.yml
jobs:
  plan:
    # ... plan job

  approval:
    needs: plan
    runs-on: ubuntu-latest
    environment: production  # Requires approval
    steps:
      - run: echo "Approved"

  apply:
    needs: approval
    # ... apply job
```

### Add Slack Notifications

```yaml
- name: Notify Slack
  uses: slackapi/slack-github-action@v1
  with:
    payload: |
      {
        "text": "Terraform apply completed for ${{ github.repository }}"
      }
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

## Debugging

### View Parsed Configuration

```bash
cd terraform
terraform console

# In console:
> local.repositories
> local.merged_configs["repo-name"]
> local.effective_rulesets["repo-name"]
```

### Debug YAML Parsing

```bash
# Validate YAML syntax
python -c "import yaml; yaml.safe_load(open('config/repositories.yml'))"

# Pretty print parsed config
python -c "
import yaml
import json
config = yaml.safe_load(open('config/repositories.yml'))
print(json.dumps(config, indent=2))
"
```
