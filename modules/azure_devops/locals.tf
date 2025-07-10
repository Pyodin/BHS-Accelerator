locals {
  organization_url = startswith(lower(var.organization_name), "https://") || startswith(lower(var.organization_name), "http://") ? var.organization_name : "https://dev.azure.com/${var.organization_name}"
}

locals {
  all_approvers = toset(flatten([for env in var.azdo_environments : env.approvers]))
  default_branch = "refs/heads/${try(values(var.azdo_environments)[0].branch_name, "dev")}"
}

locals {
  apply_env = {
    for key, env in var.az_environments : key => {
      environment_name        = env.environment_name
      service_connection_name = env.service_connection_name
      environment_key         = replace(key, "-apply", "") # Extract base env name (dev, prod, etc)
      approvers               = try(var.azdo_environments[replace(key, "-apply", "")].approvers, [])
    }
    if endswith(key, "-apply")
  }

  plan_env = {
    for key, env in var.az_environments : key => {
      environment_name        = env.environment_name
      service_connection_name = env.service_connection_name
      environment_key         = replace(key, "-plan", "") # Extract base env name (dev, prod, etc)
      approvers               = try(var.azdo_environments[replace(key, "-plan", "")].approvers, [])
    }
    if endswith(key, "-plan")
  }
}
