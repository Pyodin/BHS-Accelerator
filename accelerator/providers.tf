terraform {
  required_version = ">= 1.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.20"
    }
    # azapi = {
    #   source  = "azure/azapi"
    #   version = "~> 2.2"
    # }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 1.7"
    }
    # random = {
    #   source  = "hashicorp/random"
    #   version = "~> 3.5"
    # }
    # http = {
    #   source  = "hashicorp/http"
    #   version = "~> 3.4"
    # }
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
  storage_use_azuread = true
}

provider "azuredevops" {
  personal_access_token = var.azure_devops_personal_access_token
  org_service_url       = module.azure_devops.organization_url
}
