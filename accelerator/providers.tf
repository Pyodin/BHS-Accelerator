terraform {
  required_version = ">= 1.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.20"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "1.11.2"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {
}

# # Default provider for bootstrap resources (storage account for state, etc.)
# provider "azurerm" {
#   subscription_id = var.bootstrap_subscription_id == "" ? null : var.bootstrap_subscription_id

#   features {
#     resource_group {
#       prevent_deletion_if_contains_resources = false
#     }
#     storage {
#       data_plane_available = false
#     }
#   }
#   resource_provider_registrations = "none"
#   storage_use_azuread             = true
# }

# Environment-specific providers based on subscription configuration
# Each environment gets its own provider alias pointing to its target subscription
# Add provider blocks here when you add new environments in environments.tf

provider "azurerm" {
  alias           = "dev"
  subscription_id = local.environments.dev.subscription_id

  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    storage {
      data_plane_available = false
    }
  }
  resource_provider_registrations = "none"
  storage_use_azuread             = true
}

provider "azurerm" {
  alias           = "prod"
  subscription_id = local.environments.prod.subscription_id

  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    storage {
      data_plane_available = false
    }
  }
  resource_provider_registrations = "none"
  storage_use_azuread             = true
}

# Example for adding more environments:
# provider "azurerm" {
#   alias           = "staging"
#   subscription_id = local.environments.staging.subscription_id
#   
#   features {
#     resource_group {
#       prevent_deletion_if_contains_resources = false
#     }
#     storage {
#       data_plane_available = false
#     }
#   }
#   resource_provider_registrations = "none"
#   storage_use_azuread             = true
# }

provider "azuredevops" {
  org_service_url       = module.azure_devops.organization_url
  personal_access_token = var.azure_devops_personal_access_token
}
