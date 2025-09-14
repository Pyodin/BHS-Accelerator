# Create a new Azure DevOps project (only when not importing existing)
resource "azuredevops_project" "alz" {
  count = var.import_existing_project ? 0 : 1
  name  = title(var.project_name)
}

# Data source to reference existing project (when importing)
data "azuredevops_project" "existing" {
  count = var.import_existing_project ? 1 : 0
  name  = title(var.project_name)
}

# Local value to provide consistent project reference
locals {
  project_id   = var.import_existing_project ? data.azuredevops_project.existing[0].id : azuredevops_project.alz[0].id
  project_name = var.import_existing_project ? data.azuredevops_project.existing[0].name : azuredevops_project.alz[0].name
}
