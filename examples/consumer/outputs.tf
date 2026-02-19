# Pass through key module outputs so they are visible after apply.

output "organization" {
  description = "GitHub organization being managed"
  value       = module.github_org.organization
}

output "repository_count" {
  description = "Total number of managed repositories"
  value       = module.github_org.repository_count
}

output "repositories" {
  description = "Map of managed repositories with their URLs"
  value       = module.github_org.repositories
}

output "subscription_warnings" {
  description = "Warnings about features unavailable on current subscription tier"
  value       = module.github_org.subscription_warnings
}

output "duplicate_key_warnings" {
  description = "Warnings about duplicate keys detected across config files"
  value       = module.github_org.duplicate_key_warnings
}
