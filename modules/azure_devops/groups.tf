# ==============================================================================
# APPROVAL GROUPS CONFIGURATION
# ==============================================================================

# Create approval group for environments that need approvals
resource "azuredevops_group" "approvers" {
  for_each = {
    for env_name, env_config in var.environments : env_name => env_config
    if length(env_config.approvers) > 0
  }

  scope        = local.project_id
  display_name = "${var.project_name}-${each.key}-approvers"
  description  = "Approvers for ${var.project_name}-${each.key} environments"
}

# Local to flatten all approvers from all environments into a single map
locals {
  all_approvers = merge([
    for env_name, env_config in var.environments : {
      for approver in env_config.approvers : "${env_name}-${approver}" => {
        env_name = env_name
        approver = approver
      }
    }
    if length(env_config.approvers) > 0
  ]...)
}

# Look up each approver by their principal name
data "azuredevops_users" "approvers" {
  for_each = local.all_approvers

  principal_name = each.value.approver

  lifecycle {
    postcondition {
      condition     = length(self.users) > 0
      error_message = "No user account found for ${each.value.approver}, check you have entered a valid user principal name..."
    }
  }
}

# Local to collect all user descriptors per environment
locals {
  approvers_by_env = {
    for env_name, env_config in var.environments : env_name => toset(flatten([
      for key, data_user in data.azuredevops_users.approvers : [
        for user in data_user.users : user.descriptor
      ]
      if startswith(key, "${env_name}-")
    ]))
    if length(env_config.approvers) > 0
  }
}

# Create group membership to add all approvers to the group
resource "azuredevops_group_membership" "approvers" {
  for_each = {
    for env_name, env_config in var.environments : env_name => env_config
    if length(env_config.approvers) > 0
  }

  group   = azuredevops_group.approvers[each.key].descriptor
  members = local.approvers_by_env[each.key]
}
