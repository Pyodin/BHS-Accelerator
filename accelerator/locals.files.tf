locals {
  agent_pool_configuration  = var.use_self_hosted_agents ? "name: ${local.resource_names.version_control_system_agent_pool}" : "vmImage: ubuntu-latest"
  repository_name_templates = local.resource_names.azure_devops_repository

  pipeline_files_directory_path          = "${path.module}/pipelines/main"
  pipeline_template_files_directory_path = "${path.module}/pipelines/templates"

  pipeline_files          = fileset(local.pipeline_files_directory_path, "**/*.yaml")
  pipeline_template_files = fileset(local.pipeline_template_files_directory_path, "**/*.yaml")

  target_folder_name = ".pipelines"

  script_file_groups = {}

  # CI / CD Top Level Files
  cicd_files = { for pipeline_file in local.pipeline_files : "${local.target_folder_name}/${pipeline_file}" =>
    {
      content = templatefile("${local.pipeline_files_directory_path}/${pipeline_file}", {
        project_name              = var.project_name
        repository_name_templates = local.repository_name_templates
        ci_template_path          = "${local.target_folder_name}/${local.ci_template_file_name}"
        cd_template_path          = "${local.target_folder_name}/${local.cd_template_file_name}"
        # script_files                     = local.script_files
        # script_file_groups               = local.script_file_groups
        root_module_folder_relative_path = var.root_module_folder_relative_path
      })
    }
  }

  # CI / CD Template Files
  cicd_template_files = { for pipeline_template_file in local.pipeline_template_files : "${local.target_folder_name}/${pipeline_template_file}" =>
    {
      content = templatefile("${local.pipeline_template_files_directory_path}/${pipeline_template_file}", {
        agent_pool_configuration      = local.agent_pool_configuration
        environment_name_plan         = local.resource_names.system_environment_plan
        environment_name_apply        = local.resource_names.system_environment_apply
        variable_group_name           = local.resource_names.variable_group_name
        project_name                  = var.project_name
        repository_name_templates     = local.repository_name_templates
        service_connection_name_plan  = local.resource_names.service_connection_plan
        service_connection_name_apply = local.resource_names.service_connection_apply
        self_hosted_agent             = var.use_self_hosted_agents
      })
    }
  }

  # Create final maps of all files to be included in the repositories
  repository_files = merge(
    local.cicd_files,
    local.cicd_template_files
  )
}
