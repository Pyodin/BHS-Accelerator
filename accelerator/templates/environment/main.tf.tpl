# ${environment} Environment Configuration
terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Data sources
data "azurerm_client_config" "current" {}

# Example resource group for this environment
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_name}-${var.environment}-${var.location}"
  location = var.location

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# Add your environment-specific resources here
# Examples:
# - App Service
# - Storage Account
# - Key Vault
# - Application Insights
# - etc.
