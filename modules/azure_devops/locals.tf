locals {
  # Organization URL formatting
  organization_url = startswith(lower(var.organization_name), "https://") || startswith(lower(var.organization_name), "http://") ? var.organization_name : "https://dev.azure.com/${var.organization_name}"

  # Default branch reference
  default_branch = "refs/heads/main"

  # Common configuration for pipeline modules
  common_pipeline_config = {
    azure_tenant_id                              = var.azure_tenant_id
    azure_subscription_id                        = var.azure_subscription_id
    azure_subscription_name                      = var.azure_subscription_name
    backend_azure_resource_group_name            = var.backend_azure_resource_group_name
    backend_azure_storage_account_name           = var.backend_azure_storage_account_name
    backend_azure_storage_account_container_name = var.backend_azure_storage_account_container_name
  }

  # Read providers.tf template
  providers_template_content = file("${path.module}/templates/providers.tf")

  # Generate all deployment units (unified approach)
  deployment_units = length(var.sub_projects) == 0 ? {
    # No sub-projects: one unit per environment
    for env_name, env_config in var.environments : env_name => {
      env_name            = env_name
      project_name        = null
      display_name        = env_name
      folder_path         = env_config.root_module_folder_relative_path
      pipeline_path       = env_config.root_module_folder_relative_path == "." ? ".pipelines" : "${env_config.root_module_folder_relative_path}/.pipelines"
      pipeline_folder     = "\\${env_name}"
      env_config          = env_config
      filename_pattern    = "/${env_config.root_module_folder_relative_path}/*"
      providers_file_path = "${env_config.root_module_folder_relative_path}/providers.tf"
    }
    } : {
    # With sub-projects: one unit per environment/sub-project combination
    for combo in flatten([
      for env_name, env_config in var.environments : [
        for subproject in var.sub_projects : {
          key          = "${env_name}-${subproject}"
          env_name     = env_name
          project_name = subproject
          env_config   = env_config
        }
      ]
      ]) : combo.key => {
      env_name            = combo.env_name
      project_name        = combo.project_name
      display_name        = "${combo.env_name} ${combo.project_name}"
      folder_path         = "${combo.env_config.root_module_folder_relative_path}/${combo.project_name}"
      pipeline_path       = "${combo.env_config.root_module_folder_relative_path}/${combo.project_name}/.pipelines"
      pipeline_folder     = "\\${combo.env_name}\\${combo.project_name}"
      env_config          = combo.env_config
      filename_pattern    = "/${combo.env_config.root_module_folder_relative_path}/${combo.project_name}/*"
      providers_file_path = "${combo.env_config.root_module_folder_relative_path}/${combo.project_name}/providers.tf"
    }
  }

  # Service connection configurations per environment
  service_connections = {
    for env_name, env_config in var.environments : env_name => {
      name                = "${var.project_name}-${env_name}"
      managed_identity_id = var.service_connection_type == "managed_identity" && length(var.managed_identity_client_ids) > 0 ? var.managed_identity_client_ids[env_name] : null
      needs_approval      = length(env_config.approvers) > 1
    }
  }

  # Template variables for each environment (used for both environment templates and deployment units)
  environment_template_variables = {
    for env_name in keys(var.environments) : env_name => {
      # Common variables
      agent_pool_configuration  = var.pipeline_config.agent_pool
      project_name              = var.project_name
      repository_name_templates = var.repository_name
      self_hosted_agent         = var.pipeline_config.self_hosted_agent
      # Environment-specific variables
      environment_name        = "${var.project_name}-${env_name}"
      service_connection_name = local.service_connections[env_name].name
      variable_group_name     = "${var.project_name}-${env_name}-variables"
      ci_template_path        = "/${env_name}/.pipelines/templates/ci-template.yaml"
      cd_template_path        = "/${env_name}/.pipelines/templates/cd-template.yaml"
    }
  }

  # Template variables for each deployment unit
  deployment_template_variables = {
    for unit_key, unit in local.deployment_units : unit_key => merge(local.environment_template_variables[unit.env_name], {
      root_module_folder_relative_path = unit.folder_path
      # All deployment units use their environment's variable group
      variable_group_name = "${var.project_name}-${unit.env_name}-variables"
      # Sub-project key suffix for querying the correct backend key variable
      sub_project_key_suffix = unit.project_name != null ? "_${upper(unit.project_name)}" : ""
    })
  }

  # All files to generate (factorized approach)
  all_generated_files = merge(
    # Deployment unit files (ci.yaml, cd.yaml, providers.tf per deployment unit)
    merge([
      for unit_key, unit in local.deployment_units : {
        "${unit.pipeline_path}/ci.yaml" = {
          content = templatestring(var.pipeline_files_content.main["ci.yaml"], local.deployment_template_variables[unit_key])
        }
        "${unit.pipeline_path}/cd.yaml" = {
          content = templatestring(var.pipeline_files_content.main["cd.yaml"], local.deployment_template_variables[unit_key])
        }
        "${unit.providers_file_path}" = {
          content = local.providers_template_content
        }
      }
    ]...),
    # Environment template files (ci-template.yaml, cd-template.yaml per environment)
    merge([
      for env_name in keys(var.environments) : {
        "${env_name}/.pipelines/templates/ci-template.yaml" = {
          content = templatestring(var.pipeline_files_content.templates["ci-template.yaml"], local.environment_template_variables[env_name])
        }
        "${env_name}/.pipelines/templates/cd-template.yaml" = {
          content = templatestring(var.pipeline_files_content.templates["cd-template.yaml"], local.environment_template_variables[env_name])
        }
      }
    ]...),
    # Helper files (shared across all deployments)
    {
      for helper_name, helper_content in var.pipeline_files_content.helpers :
      ".pipelines/helpers/${helper_name}" => {
        content = helper_content
      }
    }
  )

  # Final output - all pipeline files
  all_pipeline_files = local.all_generated_files
}

