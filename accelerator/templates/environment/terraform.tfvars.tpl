# ${environment} Environment Configuration
project_name    = "${project_name}"
environment     = "${environment}"
location        = "${location}"
subscription_id = "your-subscription-id-here"

# Environment-specific tags
tags = {
  Environment = "${environment}"
  Project     = "${project_name}"
  ManagedBy   = "Terraform"
  Owner       = "DevOps Team"
}

# Add environment-specific variables here
# Examples:
# app_service_sku = "${environment == "prod" ? "P1v2" : "B1"}"
# storage_replication = "${environment == "prod" ? "GRS" : "LRS"}"
