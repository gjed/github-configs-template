# Consumer entrypoint — minimal setup to use the github-as-yaml module.
#
# Prerequisites:
#   export GITHUB_TOKEN="ghp_..."
#
# Then run:
#   terraform init && terraform plan && terraform apply

terraform {
  required_version = ">= 1.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

# Configure the GitHub provider.
# owner must be set here because provider configuration runs before module
# evaluation, so the org name from config.yml is not available at this stage.
provider "github" {
  owner = "your-org-name" # Replace with your GitHub organization name

  # Optional: rate limiting for large organizations.
  # GitHub API limit: 5000 requests/hour for authenticated requests.
  # Increase these when managing 100+ repositories.
  # read_delay_ms  = 0
  # write_delay_ms = 100
}

module "github_org" {
  # Pin to a specific version tag for reproducible builds.
  # Replace the ref with the desired release tag.
  source = "github.com/gjed/github-as-yaml//terraform?ref=v1.0.0"

  # Path to the config directory relative to this file.
  # Must be a static string — computed values are not supported.
  config_path = "${path.root}/config"

  # Optional: pass webhook secrets via environment variables or a secrets manager.
  # webhook_secrets = {
  #   MY_WEBHOOK_SECRET = var.my_webhook_secret
  # }
}
