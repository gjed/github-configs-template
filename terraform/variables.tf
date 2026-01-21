# Variables for the root module
# Currently all configuration is read from YAML files in config/

variable "webhook_secrets" {
  description = "Map of webhook secret names to their values. Keys should match the VAR_NAME in env:VAR_NAME patterns used in webhook configurations."
  type        = map(string)
  default     = {}
  sensitive   = true
}
