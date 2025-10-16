# ==============================================================================
# SERVICE CONNECTIONS (AZURE SERVICE ENDPOINTS)
# ==============================================================================

# Service connections using Workload Identity Federation (Managed Identity)
resource "azuredevops_serviceendpoint_azurerm" "service_connection_managed_identity" {
  for_each = var.service_connection_type == "managed_identity" ? var.environments : {}

  project_id                             = local.project_id
  service_endpoint_name                  = local.service_connections[each.key].name
  service_endpoint_authentication_scheme = "WorkloadIdentityFederation"

  credentials {
    serviceprincipalid = local.service_connections[each.key].managed_identity_id
  }

  azurerm_spn_tenantid      = var.azure_tenant_id
  azurerm_subscription_id   = each.value.subscription_id
  azurerm_subscription_name = "Subscription-${each.key}"

}

# Service connections using Workload Identity Federation (App Registration)
resource "azuredevops_serviceendpoint_azurerm" "service_connection_app_registration" {
  for_each = var.service_connection_type == "app_registration" ? var.environments : {}

  project_id                             = local.project_id
  service_endpoint_name                  = local.service_connections[each.key].name
  service_endpoint_authentication_scheme = "WorkloadIdentityFederation"

  # Use SPN client ID when using app registration
  credentials {
    serviceprincipalid = var.service_principal_client_ids[each.key]
  }

  azurerm_spn_tenantid      = var.azure_tenant_id
  azurerm_subscription_id   = each.value.subscription_id
  azurerm_subscription_name = "Subscription-${each.key}"

  description = "Service connection for ${each.key} environment using SPN (${var.service_principal_client_ids[each.key]}) with Workload Identity Federation"
}

# Local reference to service connections regardless of type
locals {
  service_connections_ref = var.service_connection_type == "managed_identity" ? azuredevops_serviceendpoint_azurerm.service_connection_managed_identity : azuredevops_serviceendpoint_azurerm.service_connection_app_registration
}

# ==============================================================================
# SERVICE CONNECTION SECURITY CHECKS
# ==============================================================================

# Approval checks for service connections that require approval
resource "azuredevops_check_approval" "service_connection" {
  for_each = {
    for env_name, env_config in var.environments : env_name => env_config
    if local.service_connections[env_name].needs_approval && length(env_config.approvers) > 1
  }

  project_id           = local.project_id
  target_resource_id   = local.service_connections_ref[each.key].id
  target_resource_type = "endpoint"

  requester_can_approve = false
  approvers             = [azuredevops_group.approvers[each.key].origin_id]
  timeout               = 43200 # 12 hours
}

# Exclusive lock to prevent concurrent runs of the service connection
resource "azuredevops_check_exclusive_lock" "service_connection" {
  for_each = var.environments

  project_id           = local.project_id
  target_resource_id   = local.service_connections_ref[each.key].id
  target_resource_type = "endpoint"
  timeout              = 43200 # 12 hours
}
