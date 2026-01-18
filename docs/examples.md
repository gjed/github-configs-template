# Examples

Common configuration patterns for different use cases.

## Microservices Organization

```yaml
groups:
  microservice:
    visibility: private
    has_issues: true
    delete_branch_on_merge: true
    topics:
      - microservice

repositories:
  user-service:
    groups: [microservice]
    description: "User management service"
    topics:
      - users
      - auth

  order-service:
    groups: [microservice]
    description: "Order processing service"
    topics:
      - orders
      - payments
```

## Open Source Project

```yaml
repositories:
  my-oss-project:
    description: "An awesome open source project"
    visibility: public
    has_issues: true
    has_wiki: true
    has_discussions: true
    topics:
      - opensource
      - community
    rulesets:
      protect-main:
        target: branch
        enforcement: active
        conditions:
          ref_name:
            include: ["refs/heads/main"]
        rules:
          pull_request:
            required_approving_review_count: 2
            dismiss_stale_reviews_on_push: true
```

## Monorepo with Multiple Teams

```yaml
repositories:
  platform:
    description: "Platform monorepo"
    visibility: private
    teams:
      platform-core: admin
      frontend: push
      backend: push
      devops: maintain
    rulesets:
      protect-main:
        target: branch
        enforcement: active
        conditions:
          ref_name:
            include: ["refs/heads/main"]
        rules:
          pull_request:
            required_approving_review_count: 1
          required_status_checks:
            required_checks:
              - context: "build"
              - context: "test"
```

## Private Library with Strict Controls

```yaml
repositories:
  internal-sdk:
    description: "Internal SDK for all services"
    visibility: private
    has_issues: true
    delete_branch_on_merge: true
    allow_merge_commit: false
    allow_rebase_merge: false
    allow_squash_merge: true
    teams:
      sdk-maintainers: admin
      developers: pull
    rulesets:
      protect-main:
        target: branch
        enforcement: active
        conditions:
          ref_name:
            include: ["refs/heads/main"]
        rules:
          pull_request:
            required_approving_review_count: 2
            dismiss_stale_reviews_on_push: true
            require_code_owner_review: true
          required_status_checks:
            strict_required_status_checks_policy: true
            required_checks:
              - context: "test"
              - context: "lint"
              - context: "security-scan"
```

## Documentation Repository

```yaml
repositories:
  docs:
    description: "Company documentation"
    visibility: private
    has_issues: true
    has_wiki: false
    has_discussions: true
    homepage_url: "https://docs.example.com"
    topics:
      - documentation
      - internal
    teams:
      everyone: push
      tech-writers: maintain
```
