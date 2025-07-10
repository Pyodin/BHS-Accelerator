locals {
  agent_pool_configuration  = var.use_self_hosted_agents ? "name: ${local.resource_names.version_control_system_agent_pool}" : "vmImage: ubuntu-latest"
  repository_name_templates = local.resource_names.azure_devops_repository

  pipeline_files_directory_path          = "${path.module}/pipelines/main"
  pipeline_template_files_directory_path = "${path.module}/pipelines/templates"

  pipeline_files          = fileset(local.pipeline_files_directory_path, "**/*.yaml")
  pipeline_template_files = fileset(local.pipeline_template_files_directory_path, "**/*.yaml")

  target_folder_name = ".pipelines"

  # CI / CD Top Level Files - Same file names in each branch, different content per environment
  cicd_files = merge([
    for env_name, env_config in var.environments : {
      for pipeline_file in local.pipeline_files : "${local.target_folder_name}/${pipeline_file}" =>
      {
        content = templatefile("${local.pipeline_files_directory_path}/${pipeline_file}", {
          project_name                     = var.project_name
          repository_name_templates        = local.repository_name_templates
          ci_template_path                 = "${local.target_folder_name}/${local.ci_template_file_name}"
          cd_template_path                 = "${local.target_folder_name}/${local.cd_template_file_name}"
          root_module_folder_relative_path = var.root_module_folder_relative_path
          environment_name                 = env_name
          branch_name                      = "refs/heads/${env_config.branch_name}"
        })
        branch = "refs/heads/${env_config.branch_name}"
      }
    }
  ]...)

  # CI / CD Template Files - Same file names in each branch, different content per environment
  cicd_template_files = merge([
    for env_name, env_config in var.environments : {
      for pipeline_template_file in local.pipeline_template_files : "${local.target_folder_name}/${pipeline_template_file}" =>
      {
        content = templatefile("${local.pipeline_template_files_directory_path}/${pipeline_template_file}", {
          agent_pool_configuration      = local.agent_pool_configuration
          variable_group_name           = local.resource_names.variable_group_name
          self_hosted_agent             = var.use_self_hosted_agents
          project_name                  = var.project_name
          environment_name_plan         = "${var.project_name}-$(Build.SourceBranchName)-plan"
          environment_name_apply        = "${var.project_name}-$(Build.SourceBranchName)-apply"
          service_connection_name_plan  = "sc-${var.project_name}-$(Build.SourceBranchName)-plan"
          service_connection_name_apply = "sc-${var.project_name}-$(Build.SourceBranchName)-apply"
        })
        branch = "refs/heads/${env_config.branch_name}"
      }
    }
  ]...)

  # Create final maps of all files to be included in the repositories
  repository_files = merge(
    local.cicd_files,
    local.cicd_template_files
  )
}
