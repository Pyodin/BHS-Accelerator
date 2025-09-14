resource "random_string" "name" {
  length  = 6
  numeric = true
  special = false
  upper   = false
}

module "avm-ptn-cicd-agents-and-runners" {
  source  = "Azure/avm-ptn-cicd-agents-and-runners/azurerm"
  version = "0.4.1"

  count = var.create_self_hosted_agents ? 1 : 0

  location                        = var.location
  resource_group_name             = var.resource_group_name
  resource_group_creation_enabled = false
  postfix                         = random_string.name.result

  version_control_system_organization          = var.azure_devops_organization_url
  version_control_system_type                  = "azuredevops"
  use_private_networking                       = var.use_private_networking
  version_control_system_personal_access_token = var.azure_devops_agent_pat
  version_control_system_pool_name             = var.agent_pool_name

  # Virtual network configuration - required when using private networking
  virtual_network_creation_enabled = var.use_private_networking

  # Compute configuration
  compute_types = var.compute_types

  # Container Instance settings
  container_instance_count                  = var.container_instance_count
  container_instance_container_cpu          = var.container_instance_cpu
  container_instance_container_cpu_limit    = var.container_instance_cpu
  container_instance_container_memory       = var.container_instance_memory
  container_instance_container_memory_limit = var.container_instance_memory

  # Container App settings
  container_app_container_cpu            = var.container_app_cpu
  container_app_container_memory         = var.container_app_memory
  container_app_min_execution_count      = var.container_app_min_execution_count
  container_app_max_execution_count      = var.container_app_max_execution_count
  container_app_polling_interval_seconds = var.container_app_polling_interval_seconds

  enable_telemetry = false
  tags             = var.tags
}
