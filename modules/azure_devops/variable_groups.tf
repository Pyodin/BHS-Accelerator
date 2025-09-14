# ==============================================================================
# PIPELINE VARIABLE GROUPS
# ==============================================================================

# Variable groups for pipelines per environment
resource "azuredevops_variable_group" "pipeline" {
  for_each = var.environments

  project_id   = local.project_id
  name         = "${var.project_name}-${each.key}-variables"
  description  = "Variable group for ${each.key} environment pipelines"
  allow_access = true

  # Backend configuration variables
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

  # Sub-project specific backend keys (only when sub-projects are defined)
  dynamic "variable" {
    for_each = var.sub_projects
    content {
      name  = "BACKEND_AZURE_STORAGE_ACCOUNT_CONTAINER_KEY_NAME_${upper(variable.value)}"
      value = "${each.key}-${variable.value}-terraform.tfstate"
    }
  }

  # Subscription configuration variables
  variable {
    name  = "TARGET_SUBSCRIPTION_ID"
    value = each.value.subscription_id
  }

  variable {
    name  = "BOOTSTRAP_SUBSCRIPTION_ID"
    value = var.azure_subscription_id
  }
}
