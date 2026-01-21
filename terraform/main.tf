# GitHub Organization Infrastructure as Code
# Configuration is loaded from YAML files in the config/ directory

terraform {
  required_version = ">= 1.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }

  # Uncomment to configure remote backend for team collaboration
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "github-org/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

provider "github" {
  # Organization is read from config/config.yml
  owner = local.github_org

  # Token is read from GITHUB_TOKEN environment variable
  # Token must have repo and admin:org scopes
}

# Manage all repositories using YAML configuration
module "repositories" {
  source = "./modules/repository"

  for_each = local.repositories

  name         = each.value.name
  description  = each.value.description
  homepage_url = each.value.homepage_url
  visibility   = each.value.visibility

  has_wiki        = each.value.has_wiki
  has_issues      = each.value.has_issues
  has_projects    = each.value.has_projects
  has_downloads   = each.value.has_downloads
  has_discussions = each.value.has_discussions

  allow_merge_commit          = each.value.allow_merge_commit
  allow_squash_merge          = each.value.allow_squash_merge
  allow_rebase_merge          = each.value.allow_rebase_merge
  allow_auto_merge            = each.value.allow_auto_merge
  allow_update_branch         = each.value.allow_update_branch
  delete_branch_on_merge      = each.value.delete_branch_on_merge
  web_commit_signoff_required = each.value.web_commit_signoff_required

  topics = each.value.topics
  teams  = each.value.teams

  license_template = each.value.license_template

  # Apply rulesets based on repository groups
  rulesets = each.value.rulesets

  # Apply Actions permissions configuration
  actions = each.value.actions

  # Apply webhooks from groups and repo-specific definitions
  webhooks = each.value.webhooks

  # Dependency update configurations
  dependabot         = each.value.dependabot
  renovate           = each.value.renovate
  renovate_file_path = each.value.renovate_file_path
}

# Organization-level Actions permissions
# Only created when actions configuration is specified in config.yml
resource "github_actions_organization_permissions" "this" {
  count = local.org_actions_config != null ? 1 : 0

  # Which repositories can use Actions: all, none, selected
  enabled_repositories = try(local.org_actions_config.enabled_repositories, "all")

  # Which actions are allowed: all, local_only, selected
  allowed_actions = try(local.org_actions_config.allowed_actions, "all")

  # Configuration for "selected" allowed_actions policy
  dynamic "allowed_actions_config" {
    for_each = try(local.org_actions_config.allowed_actions, "all") == "selected" ? [1] : []
    content {
      github_owned_allowed = try(local.org_actions_config.allowed_actions_config.github_owned_allowed, true)
      verified_allowed     = try(local.org_actions_config.allowed_actions_config.verified_allowed, true)
      patterns_allowed     = try(local.org_actions_config.allowed_actions_config.patterns_allowed, [])
    }
  }
}

# Organization-level workflow permissions (GITHUB_TOKEN defaults)
# Only created when actions configuration is specified in config.yml
resource "github_actions_organization_workflow_permissions" "this" {
  count = local.org_actions_config != null ? 1 : 0

  organization_slug = local.github_org

  # Default GITHUB_TOKEN permissions: read or write
  # Secure default: read (principle of least privilege)
  default_workflow_permissions = try(local.org_actions_config.default_workflow_permissions, "read")

  # Whether Actions can approve pull request reviews
  # Secure default: false
  can_approve_pull_request_reviews = try(local.org_actions_config.can_approve_pull_request_reviews, false)
}
