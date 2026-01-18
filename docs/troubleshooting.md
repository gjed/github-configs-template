# Troubleshooting

Common issues and their solutions.

## Common Issues

### Using the wrong GitHub provider

**Cause**: Using the deprecated HashiCorp GitHub provider instead of the community-maintained one.

**Solution**: Use the `integrations/github` provider, not `hashicorp/github`:

```hcl
terraform {
  required_providers {
    github = {
      source  = "integrations/github"  # Correct
      # source = "hashicorp/github"    # Wrong - deprecated
      version = "~> 6.0"
    }
  }
}
```

### "Resource not found" errors

**Cause**: The GitHub token doesn't have access to the organization or repository.

**Solution**: Ensure your token has the correct scopes and organization access:

- For personal repos: `repo` scope
- For org repos: `repo` + `admin:org` scopes
- Check if SSO is required and authorize the token

### "Ruleset not supported" errors

**Cause**: Rulesets require GitHub Pro, Team, or Enterprise for private repositories.

**Solution**: Either:

- Use a public repository (rulesets work on Free tier)
- Upgrade to GitHub Pro/Team
- Remove ruleset configuration for private repos on Free tier

### Terraform state conflicts

**Cause**: Multiple people running Terraform simultaneously.

**Solution**: Use a remote backend for state storage:

```hcl
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "github-repos/terraform.tfstate"
    region = "us-east-1"
  }
}
```

### Rate limiting

**Cause**: GitHub API rate limit exceeded (~5000 requests/hour).

**Solution**:

- Reduce the number of repositories managed in a single run
- Use `-parallelism=1` to slow down API calls
- Wait for the rate limit to reset

## FAQ

### Can I import existing repositories?

Yes, use `terraform import`:

```bash
terraform import 'module.repositories["my-repo"].github_repository.this' my-repo
```

### What happens if I remove a repository from config?

By default, the repository is archived (not deleted). Set `archive_on_destroy = false` to delete instead.

### Can I manage repositories across multiple organizations?

Currently, this template manages one organization at a time. For multiple orgs, use separate
instances with different state files.

### How do I handle sensitive repository settings?

Use Terraform variables or environment variables for sensitive values. Never commit tokens to the repository.

## Related Documentation

- [Terraform GitHub Provider](https://registry.terraform.io/providers/integrations/github/latest/docs)
- [GitHub Repository Rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets)
- [GitHub API Rate Limits](https://docs.github.com/en/rest/overview/resources-in-the-rest-api#rate-limiting)
