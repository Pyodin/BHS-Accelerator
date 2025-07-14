resource "azuredevops_group" "alz_approvers" {
  scope        = azuredevops_project.alz.id
  display_name = "${var.project_name}-approvers"
  description  = "Approvers for the ${var.project_name} project in Azure DevOps"
}

data "azuredevops_users" "alz" {
  for_each       = { for approver in var.approvers : approver => approver }
  
  principal_name = each.key
  lifecycle {
    postcondition {
      condition     = length(self.users) > 0
      error_message = "No user account found for ${each.value}, check you have entered a valid user principal name..."
    }
  }
}

locals {
  approvers = toset(flatten([for approver in data.azuredevops_users.alz :
    [for user in approver.users : user.descriptor]
  ]))
}

resource "azuredevops_group_membership" "alz_approvers" {
  group   = azuredevops_group.alz_approvers.descriptor
  members = local.approvers
}
