locals {
  # Sanitized project name for Azure resources (removes spaces and invalid characters)
  project_name_sanitized = lower(replace(replace(var.project_name, " ", ""), "/[^a-zA-Z0-9-]/", "-"))

  # Azure configuration
  azure_config = {
    tenant_id         = data.azurerm_client_config.current.tenant_id
    subscription_id   = data.azurerm_client_config.current.subscription_id
    subscription_name = data.azurerm_subscription.current.display_name
  }

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


  # ==============================================================================
  # RESOURCE NAMING - Global resource names
  # ==============================================================================

  resource_names = {
    resource_group_name             = "rg-${local.project_name_sanitized}-devops"
    storage_account_state           = module.naming.storage_account.name_unique
    storage_account_state_container = "tfstate"
    azure_devops_repository         = "tf-${local.project_name_sanitized}"
    container_registry              = module.naming.container_registry.name_unique
  }

  # Backend configuration
  backend_config = {
    resource_group_name  = local.resource_names.resource_group_name
    storage_account_name = local.resource_names.storage_account_state
    container_name       = local.resource_names.storage_account_state_container
  }

  # ==============================================================================
  # ENVIRONMENT-SPECIFIC CONFIGURATION
  # ==============================================================================

  # Environments with resource names (references computed separately to avoid cycles)
  environments = {
    for env_name, env_config in var.environments : env_name => {
      # Original configuration
      approvers                        = env_config.approvers
      root_module_folder_relative_path = env_config.root_module_folder_relative_path
      subscription_id                  = env_config.subscription_id

      # Computed resource names specific to this environment
      managed_identity_name     = "uai-${local.project_name_sanitized}-${env_name}"
      federated_credential_name = "fc-${local.project_name_sanitized}-${env_name}"
    }
  }

  # Simplified managed identities configuration for azure module
  managed_identities = {
    for env_name, env_config in var.environments :
    env_name => local.environments[env_name].managed_identity_name
  }

  # Simplified federated credentials configuration (computed after modules)
  federated_credentials = var.service_connection_type == "managed_identity" ? {
    for env_name, env_config in var.environments :
    env_name => {
      user_assigned_managed_identity_key = env_name
      federated_credential_subject       = module.azure_devops.subjects[env_name]
      federated_credential_issuer        = module.azure_devops.issuers[env_name]
      federated_credential_name          = local.environments[env_name].federated_credential_name
    }
  } : {}

  # Legacy compatibility - managed identity client IDs by environment (computed after modules)
  managed_identity_client_ids_by_environment = var.service_connection_type == "managed_identity" ? {
    for env_name, env_config in var.environments :
    env_name => module.azure.user_assigned_managed_identity_client_ids[env_name]
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
