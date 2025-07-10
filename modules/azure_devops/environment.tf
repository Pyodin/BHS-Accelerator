resource "azuredevops_environment" "alz" {
  for_each   = var.az_environments

  name       = each.value.environment_name
  project_id = azuredevops_project.alz.id
}
