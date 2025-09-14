terraform {
  required_version = ">= 1.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.20"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 1.7"
    }
  }
}

provider "azurerm" {
  subscription_id = var.bootstrap_subscription_id == "" ? null : var.bootstrap_subscription_id

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

provider "azuredevops" {
  org_service_url       = module.azure_devops.organization_url
  personal_access_token = var.azure_devops_personal_access_token
}
