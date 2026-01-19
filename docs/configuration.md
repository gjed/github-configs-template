# Configuration Reference

This document provides a complete reference for all configuration options.

## Repository Settings

| Field | Type | Default | Description |
| ----- | ---- | ------- | ----------- |
| `description` | string | `""` | Repository description |
| `visibility` | string | `"private"` | One of: `public`, `private`, `internal` |
| `has_issues` | bool | `true` | Enable issues |
| `has_wiki` | bool | `false` | Enable wiki |
| `has_projects` | bool | `false` | Enable projects |
| `has_discussions` | bool | `false` | Enable discussions |
| `is_template` | bool | `false` | Mark as template repository |
| `archived` | bool | `false` | Archive the repository |
| `archive_on_destroy` | bool | `true` | Archive instead of delete |
| `delete_branch_on_merge` | bool | `true` | Auto-delete head branches |
| `allow_merge_commit` | bool | `true` | Allow merge commits |
| `allow_squash_merge` | bool | `true` | Allow squash merging |
| `allow_rebase_merge` | bool | `true` | Allow rebase merging |
| `allow_auto_merge` | bool | `false` | Allow auto-merge |
| `topics` | list | `[]` | Repository topics |
| `homepage_url` | string | `""` | Repository homepage URL |
| `vulnerability_alerts` | bool | `true` | Enable vulnerability alerts |

## Configuration Groups

Groups allow you to share settings across multiple repositories:

```yaml
groups:
  default:
    has_issues: true
    delete_branch_on_merge: true
    vulnerability_alerts: true

  public-libs:
    visibility: public
    has_wiki: true

repositories:
  my-lib:
    groups:
      - default
      - public-libs
    description: "Uses settings from both groups"
```

Settings are merged in order: base defaults -> groups (in order) -> repository-specific.

## Repository Rulesets

Define branch protection rules using rulesets:

```yaml
repositories:
  my-app:
    rulesets:
      protect-main:
        target: branch
        enforcement: active
        conditions:
          ref_name:
            include:
              - "refs/heads/main"
        rules:
          pull_request:
            required_approving_review_count: 1
            dismiss_stale_reviews_on_push: true
            require_last_push_approval: true
          required_status_checks:
            strict_required_status_checks_policy: true
            required_checks:
              - context: "ci"
```

### Ruleset Fields

| Field | Type | Description |
| ----- | ---- | ----------- |
| `target` | string | `branch` or `tag` |
| `enforcement` | string | `active`, `evaluate`, or `disabled` |
| `conditions.ref_name.include` | list | Patterns to include |
| `conditions.ref_name.exclude` | list | Patterns to exclude |
| `rules.pull_request` | object | PR requirements |
| `rules.required_status_checks` | object | CI check requirements |
| `rules.required_signatures` | bool | Require signed commits |

## Team Access

Grant teams access to repositories:

```yaml
repositories:
  my-app:
    teams:
      developers: push
      maintainers: maintain
      admins: admin
```

Permission levels: `pull`, `triage`, `push`, `maintain`, `admin`

## Collaborators

Add individual collaborators:

```yaml
repositories:
  my-app:
    collaborators:
      external-contributor: push
```
