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
}
