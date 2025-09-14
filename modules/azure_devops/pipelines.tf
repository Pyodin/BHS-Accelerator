# ==============================================================================
# CI/CD PIPELINE DEFINITIONS
# ==============================================================================

# Create CI pipelines for all deployment units
resource "azuredevops_build_definition" "ci_pipeline" {
  for_each = local.deployment_units

  project_id = local.project_id
  name       = "${each.value.display_name} - CI"
  path       = each.value.pipeline_folder

  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type           = "TfsGit"
    repo_id             = azuredevops_git_repository.terraform.id
    branch_name         = azuredevops_git_repository.terraform.default_branch
    yml_path            = "${each.value.pipeline_path}/ci.yaml"
    report_build_status = true
  }

  variable_groups = [azuredevops_variable_group.pipeline[each.value.env_name].id]

  depends_on = [
    azuredevops_git_repository_file.pipeline_files,
    azuredevops_environment.environment,
    azuredevops_serviceendpoint_azurerm.service_connection_managed_identity,
    azuredevops_serviceendpoint_azurerm.service_connection_app_registration
  ]
}

# Create CD pipelines for all deployment units
resource "azuredevops_build_definition" "cd_pipeline" {
  for_each = local.deployment_units

  project_id = local.project_id
  name       = "${each.value.display_name} - CD"
  path       = each.value.pipeline_folder

  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type           = "TfsGit"
    repo_id             = azuredevops_git_repository.terraform.id
    branch_name         = azuredevops_git_repository.terraform.default_branch
    yml_path            = "${each.value.pipeline_path}/cd.yaml"
    report_build_status = true
  }

  variable_groups = [azuredevops_variable_group.pipeline[each.value.env_name].id]

  depends_on = [
    azuredevops_git_repository_file.pipeline_files,
    azuredevops_environment.environment,
    azuredevops_serviceendpoint_azurerm.service_connection_managed_identity,
    azuredevops_serviceendpoint_azurerm.service_connection_app_registration
  ]
}

# ==============================================================================
# PIPELINE AUTHORIZATIONS
# ==============================================================================

# CI Pipeline authorizations for all deployment units
resource "azuredevops_pipeline_authorization" "ci_environment" {
  for_each = local.deployment_units

  project_id  = local.project_id
  resource_id = azuredevops_environment.environment[each.value.env_name].id
  type        = "environment"
  pipeline_id = azuredevops_build_definition.ci_pipeline[each.key].id
}

resource "azuredevops_pipeline_authorization" "ci_service_connection" {
  for_each = local.deployment_units

  project_id  = local.project_id
  resource_id = local.service_connections_ref[each.value.env_name].id
  type        = "endpoint"
  pipeline_id = azuredevops_build_definition.ci_pipeline[each.key].id
}

# CD Pipeline authorizations for all deployment units
resource "azuredevops_pipeline_authorization" "cd_environment" {
  for_each = local.deployment_units

  project_id  = local.project_id
  resource_id = azuredevops_environment.environment[each.value.env_name].id
  type        = "environment"
  pipeline_id = azuredevops_build_definition.cd_pipeline[each.key].id
}

resource "azuredevops_pipeline_authorization" "cd_service_connection" {
  for_each = local.deployment_units

  project_id  = local.project_id
  resource_id = local.service_connections_ref[each.value.env_name].id
  type        = "endpoint"
  pipeline_id = azuredevops_build_definition.cd_pipeline[each.key].id
}
