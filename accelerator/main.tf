# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"

  suffix = [
    local.project_name_sanitized,
    var.location
  ]
}

module "azure" {
  source = "../modules/azure"

  project_name = local.project_name_sanitized
  location     = var.location

  resource_group_name              = local.resource_names.resource_group_name
  user_assigned_managed_identities = var.service_connection_type == "managed_identity" ? local.managed_identities : {}
  federated_credentials            = var.service_connection_type == "managed_identity" ? local.federated_credentials : {}
  storage_account_name             = local.resource_names.storage_account_state
  storage_account_state_container  = local.resource_names.storage_account_state_container
  container_registry_name          = local.resource_names.container_registry

  # Self-hosted agents configuration
  azure_devops_organization_url = local.organization_url
  azure_devops_agent_pat        = var.azure_devops_personal_access_token

  agent_pool_name           = var.self_hosted_agent_pool_name
  create_self_hosted_agents = var.use_self_hosted_agents && var.create_container_agents
  use_private_networking    = var.use_private_networking
  compute_types             = var.compute_types

  # Container Instance settings
  container_instance_count  = var.container_instance_count
  container_instance_cpu    = var.container_instance_cpu
  container_instance_memory = var.container_instance_memory

  # Container App settings
  container_app_cpu                      = var.container_app_cpu
  container_app_memory                   = var.container_app_memory
  container_app_min_execution_count      = var.container_app_min_execution_count
  container_app_max_execution_count      = var.container_app_max_execution_count
  container_app_polling_interval_seconds = var.container_app_polling_interval_seconds

  tags = local.tags
}

module "azure_devops" {
  source = "../modules/azure_devops"

  # Core configuration
  organization_name = var.azure_devops_organization_name
  project_name      = var.project_name

  # Project import configuration
  import_existing_project = var.import_existing_azure_devops_project
  existing_project_id     = var.existing_azure_devops_project_id

  # Service connection configuration
  service_connection_type = var.service_connection_type

  # Azure configuration
  azure_tenant_id         = local.azure_config.tenant_id
  azure_subscription_id   = local.azure_config.subscription_id
  azure_subscription_name = local.azure_config.subscription_name

  # Managed identities (only when using managed identity auth)
  managed_identity_client_ids = var.service_connection_type == "managed_identity" ? local.managed_identity_client_ids_by_environment : {}

  # Backend configuration
  backend_azure_resource_group_name            = local.backend_config.resource_group_name
  backend_azure_storage_account_name           = local.backend_config.storage_account_name
  backend_azure_storage_account_container_name = local.backend_config.container_name

  # Repository configuration
  repository_name = local.resource_names.azure_devops_repository
  min_approvers   = var.min_approvers

  # Environment configuration
  environments = local.environments
  sub_projects = var.sub_projects

  # Pipeline configuration
  pipeline_files_content      = local.pipeline_files_content
  pipeline_config             = local.pipeline_config
  self_hosted_agent_pool_name = var.self_hosted_agent_pool_name
  apply_branch_policy         = var.apply_branch_policy
}
