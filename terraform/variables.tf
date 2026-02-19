# Variables for the GitHub org Terraform module

variable "config_path" {
  description = "Absolute path to the directory containing config.yml, group/, repository/, ruleset/, and webhook/ subdirectories. Consumers should set this to path.root + \"/config\". Must be a static string - computed values are not supported because file() and fileset() are evaluated at plan time."
  type        = string
}

variable "webhook_secrets" {
  description = "Map of webhook secret names to their values. Keys should match the VAR_NAME in env:VAR_NAME patterns used in webhook configurations."
  type        = map(string)
  default     = {}
  sensitive   = true
}
