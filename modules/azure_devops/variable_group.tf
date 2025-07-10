resource "azuredevops_variable_group" "alz" {
  project_id   = azuredevops_project.alz.id
  name         = var.variable_group_name
  description  = "Variable group for ${var.project_name} project"
  allow_access = true

  variable {
    name  = "BACKEND_AZURE_RESOURCE_GROUP_NAME"
    value = var.backend_azure_resource_group_name
  }

  variable {
    name  = "BACKEND_AZURE_STORAGE_ACCOUNT_NAME"
    value = var.backend_azure_storage_account_name
  }

  variable {
    name  = "BACKEND_AZURE_STORAGE_ACCOUNT_CONTAINER_NAME"
    value = var.backend_azure_storage_account_container_name
  }

  # # Environment mappings - one variable per environment for plan stage
  # dynamic "variable" {
  #   for_each = var.environment_map_plan
  #   content {
  #     name  = "ENVIRONMENT_MAP_PLAN[${variable.key}]"
  #     value = variable.value
  #   }
  # }

  # # Environment mappings - one variable per environment for apply stage
  # dynamic "variable" {
  #   for_each = var.environment_map_apply
  #   content {
  #     name  = "ENVIRONMENT_MAP_APPLY[${variable.key}]"
  #     value = variable.value
  #   }
  # }

  # # Service connection mappings - one variable per environment for plan stage
  # dynamic "variable" {
  #   for_each = var.service_connection_map_plan
  #   content {
  #     name  = "SERVICE_CONNECTION_MAP_PLAN[${variable.key}]"
  #     value = variable.value
  #   }
  # }

  # # Service connection mappings - one variable per environment for apply stage
  # dynamic "variable" {
  #   for_each = var.service_connection_map_apply
  #   content {
  #     name  = "SERVICE_CONNECTION_MAP_APPLY[${variable.key}]"
  #     value = variable.value
  #   }
  # }
}
