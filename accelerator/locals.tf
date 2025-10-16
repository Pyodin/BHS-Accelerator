locals {
  # Sanitized project name for Azure resources (removes spaces and invalid characters)
  project_name_sanitized = lower(replace(replace(var.project_name, " ", ""), "/[^a-zA-Z0-9-]/", "-"))

  organization_url = startswith(lower(var.azure_devops_organization_name), "https://") || startswith(lower(var.azure_devops_organization_name), "http://") ? var.azure_devops_organization_name : "https://dev.azure.com/${var.azure_devops_organization_name}"

  # Pipeline configuration
  pipeline_config = {
    templates_path = ".pipelines/templates"
    helpers_path   = ".pipelines/helpers"

    files = {
      ci_template = "ci-template.yaml"
      cd_template = "cd-template.yaml"
      ci_main     = "ci.yaml"
      cd_main     = "cd.yaml"
    }

    # Agent configuration - dynamically set based on use_self_hosted_agents
    agent_pool        = var.use_self_hosted_agents ? "name: '${var.self_hosted_agent_pool_name}'" : "name: 'Azure Pipelines'"
    self_hosted_agent = var.use_self_hosted_agents
  }


  # Azure DevOps repository name
  azure_devops_repository = "tf-${local.project_name_sanitized}"

  # ==============================================================================
  # ENVIRONMENT-SPECIFIC CONFIGURATION  
  # ==============================================================================

  # Centralized environment resources configuration (replaces azure/locals.tf logic)
  environment_resources = {
    for env_name, env_config in local.environments : env_name => {
      # Resource naming (moved from azure module)
      resource_group_name             = "rg-${local.project_name_sanitized}-devops-${env_name}"
      storage_account_name            = "st${replace("${local.project_name_sanitized}terraform${env_name}", "-", "")}"
      storage_account_state_container = "tfstate"
      container_registry_name         = "acr${local.project_name_sanitized}${env_name}"
      managed_identity_name           = "uai-${local.project_name_sanitized}-${env_name}"
      federated_credential_name       = "fc-${local.project_name_sanitized}-${env_name}"
      service_principal_display_name  = "spn-${local.project_name_sanitized}-${env_name}"
      
      # Backend configuration
      backend_azure_storage_account_name           = replace("${local.project_name_sanitized}${env_name}", "-", "")
      backend_azure_storage_account_container_name = "tfstate"
      
      # Environment metadata
      subscription_id = env_config.subscription_id
    }
  }

  # Federated credentials configuration (computed after Azure DevOps module)
  # Configure federated credentials when:
  # - Creating managed identity (service_connection_type == "managed_identity")
  # - Using app registration (service_connection_type == "app_registration") - both importing existing and creating new
  federated_credentials = (var.service_connection_type == "managed_identity" || var.service_connection_type == "app_registration") ? {
    for env_name in keys(local.environments) : env_name => {
      subject = module.azure_devops.subjects[env_name]
      issuer  = module.azure_devops.issuers[env_name]
    }
  } : {}

  # ==============================================================================
  # TAGS CONFIGURATION
  # ==============================================================================

  tags = merge(
    {
      "Project"   = var.project_name,
      "Location"  = var.location,
      "managedBy" = "Terraform"
    },
    var.tags
  )
}

