# Create a group for each environment that has approvers
resource "azuredevops_group" "environment_approvers" {
  for_each = var.azdo_environments

  scope        = azuredevops_project.alz.id
  display_name = "${var.project_name}-${each.key}-approvers"
  description  = "Approvers for the ${each.key} environment in the ${var.project_name} project"
}

data "azuredevops_users" "alz" {
  for_each = local.all_approvers

  principal_name = each.key
  lifecycle {
    postcondition {
      condition     = length(self.users) > 0
      error_message = "No user account found for ${each.value}, check you have entered a valid user principal name..."
    }
  }
}

resource "azuredevops_group_membership" "environment_approvers" {
  for_each = var.azdo_environments

  group = azuredevops_group.environment_approvers[each.key].descriptor
  members = toset(flatten([
    for approver in each.value.approvers : [
      for user in data.azuredevops_users.alz[approver].users : user.descriptor
    ]
  ]))
}
