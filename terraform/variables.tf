# Variables for the root module
# Currently all configuration is read from YAML files in config/

variable "webhook_secrets" {
  description = "Map of webhook secret names to their values. Keys should match the VAR_NAME in env:VAR_NAME patterns used in webhook configurations."
  type        = map(string)
  default     = {}
  sensitive   = true
}

# GitHub API Rate Limiting
# GitHub API limits: 5000 requests/hour for authenticated requests
# For large organizations (100+ repos), consider increasing these values

variable "github_read_delay_ms" {
  description = "Delay in milliseconds between read API calls. Increase for large orgs to avoid rate limiting."
  type        = number
  default     = 0
}

variable "github_write_delay_ms" {
  description = "Delay in milliseconds between write API calls. Increase for large orgs to avoid rate limiting."
  type        = number
  default     = 100
}
