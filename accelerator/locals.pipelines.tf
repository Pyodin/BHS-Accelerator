locals {
  # Environment filtering for pipelines - just get the keys we need
  plan_environment_keys = [
    for key in keys(local.environments) : key
    if endswith(key, "-plan")
  ]

  apply_environment_keys = [
    for key in keys(local.environments) : key
    if endswith(key, "-apply")
  ]
}

locals {
  pipelines = {
    ci = {
      pipeline_name           = local.resource_names.version_control_system_pipeline_name_ci
      pipeline_file_name      = "${local.target_folder_name}/${local.ci_file_name}"
      environment_keys        = local.plan_environment_keys
      service_connection_keys = local.plan_environment_keys
    }

    cd = {
      pipeline_name           = local.resource_names.version_control_system_pipeline_name_cd
      pipeline_file_name      = "${local.target_folder_name}/${local.cd_file_name}"
      environment_keys        = concat(local.plan_environment_keys, local.apply_environment_keys)
      service_connection_keys = concat(local.plan_environment_keys, local.apply_environment_keys)
    }
  }
}
