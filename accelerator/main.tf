
# Deploy Azure resources for dev environment
module "azure_dev" {
  source = "../modules/azure"

  providers = {
    azurerm.target = azurerm.dev
  }

  count = contains(keys(local.environments), "dev") ? 1 : 0

  project_name     = local.project_name_sanitized
  location         = var.location
  environment_name = "dev"

  environment_resources     = local.environment_resources["dev"]
  create_managed_identity   = var.service_connection_type == "managed_identity"
  create_service_principal  = var.service_connection_type == "app_registration" && !var.import_existing_spn
  import_existing_spn       = var.service_connection_type == "app_registration" && var.import_existing_spn
  federated_credentials     = local.federated_credentials["dev"]
  existing_spn_display_name = var.service_connection_type == "app_registration" && var.import_existing_spn ? var.existing_service_principals["dev"].display_name : ""

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

# Deploy Azure resources for prod environment
module "azure_prod" {
  source = "../modules/azure"

  providers = {
    azurerm.target = azurerm.prod
  }

  count = contains(keys(local.environments), "prod") ? 1 : 0

  project_name     = local.project_name_sanitized
  location         = var.location
  environment_name = "prod"

  environment_resources     = local.environment_resources["prod"]
  create_managed_identity   = var.service_connection_type == "managed_identity"
  create_service_principal  = var.service_connection_type == "app_registration" && !var.import_existing_spn
  import_existing_spn       = var.service_connection_type == "app_registration" && var.import_existing_spn
  federated_credentials     = local.federated_credentials["prod"]
  existing_spn_display_name = var.service_connection_type == "app_registration" && var.import_existing_spn ? var.existing_service_principals["prod"].display_name : ""

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

  azure_tenant_id = data.azurerm_client_config.current.tenant_id

  # Managed identities (only when using managed identity auth)
  managed_identity_client_ids = var.service_connection_type == "managed_identity" ? {
    dev  = module.azure_dev[0].managed_identity_client_id
    prod = module.azure_prod[0].managed_identity_client_id
  } : {}

  # Service principals (when using app registration auth with created SPNs)
  service_principal_client_ids = var.service_connection_type == "app_registration" ? {
    dev  = module.azure_dev[0].service_principal_client_id
    prod = module.azure_prod[0].service_principal_client_id
  } : {}

  # Environment resources configuration (supports multiple backends)
  environment_resources = local.environment_resources

  # Repository configuration
  repository_name = "${local.project_name_sanitized}-iac"
  min_approvers   = var.min_approvers

  # Environment configuration
  environments = local.environments
  sub_projects = var.sub_projects

  # Pipeline configuration
  pipeline_files_content       = local.pipeline_files_content
  pipeline_config              = local.pipeline_config
  self_hosted_agent_pool_name  = var.self_hosted_agent_pool_name
  apply_branch_policy          = var.apply_branch_policy
}
