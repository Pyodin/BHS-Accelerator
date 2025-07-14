# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"

  suffix = [
    var.project_name,
    var.environment,
    var.location
  ]
}

module "azure" {
  source = "../modules/azure"

  project_name = var.project_name
  environment  = var.environment
  location     = var.location

  resource_group_identity          = local.resource_names.resource_group_identity
  user_assigned_managed_identities = local.managed_identities
  federated_credentials            = local.federated_credentials

  # Storage account configuration
  resource_group_state             = local.resource_names.resource_group_state
  storage_account_name             = local.resource_names.storage_account_state
  storage_account_state_container  = local.resource_names.storage_account_state_container
  storage_account_replication_type = "LRS"

  additional_role_assignment_principal_ids = {}

  tags = local.tags
}

module "azure_devops" {
  source = "../modules/azure_devops"

  azure_tenant_id         = data.azurerm_client_config.current.tenant_id
  azure_subscription_id   = data.azurerm_client_config.current.subscription_id
  azure_subscription_name = data.azurerm_subscription.current.display_name

  managed_identity_client_ids = module.azure.user_assigned_managed_identity_client_ids

  backend_azure_resource_group_name            = local.resource_names.resource_group_state
  backend_azure_storage_account_name           = local.resource_names.storage_account_state
  backend_azure_storage_account_container_name = local.resource_names.storage_account_state_container

  organization_name      = var.azure_devops_organization_name
  project_name           = var.project_name
  use_self_hosted_agents = var.use_self_hosted_agents
  environments           = local.environments
  repository_name        = local.resource_names.azure_devops_repository
  approvers              = var.apply_approvers
  variable_group_name    = local.resource_names.variable_group_name

  repository_files = local.repository_files
  pipelines        = local.pipelines
}

