resource "azuredevops_git_repository" "alz" {
  depends_on = [azuredevops_environment.alz]

  project_id     = azuredevops_project.alz.id
  name           = var.repository_name
  default_branch = local.default_branch

  initialization {
    init_type = "Clean"
  }
}

# Create branches for each environment (excluding the default branch since it's created automatically)
resource "azuredevops_git_repository_branch" "environment_branches" {
  for_each = toset([for env_name, env_config in var.azdo_environments : env_config.branch_name if "refs/heads/${env_config.branch_name}" != local.default_branch])

  repository_id = azuredevops_git_repository.alz.id
  name          = each.value
  ref_branch    = azuredevops_git_repository.alz.default_branch
}

resource "azuredevops_git_repository_file" "alz" {
  for_each = var.repository_files

  depends_on = [
    azuredevops_git_repository.alz,
    azuredevops_git_repository_branch.environment_branches
  ]

  repository_id       = azuredevops_git_repository.alz.id
  file                = each.key
  content             = each.value.content
  branch              = lookup(each.value, "branch", local.default_branch)
  commit_message      = "[skip ci]"
  overwrite_on_create = true
}

resource "azuredevops_branch_policy_min_reviewers" "alz" {
  depends_on = [
    azuredevops_git_repository_file.alz,
    azuredevops_git_repository_branch.environment_branches
  ]

  project_id = azuredevops_project.alz.id

  enabled  = length(flatten([for env in var.azdo_environments : env.approvers])) > 0
  blocking = true

  settings {
    reviewer_count                         = 1
    submitter_can_vote                     = false
    last_pusher_cannot_approve             = true
    allow_completion_with_rejects_or_waits = false
    on_push_reset_approved_votes           = true

    # Dynamic scope for each environment branch that has approvers
    dynamic "scope" {
      for_each = [for env in var.azdo_environments : env.branch_name if length(env.approvers) > 0]

      content {
        repository_id  = azuredevops_git_repository.alz.id
        repository_ref = "refs/heads/${scope.value}"
        match_type     = "Exact"
      }
    }
  }
}

resource "azuredevops_branch_policy_merge_types" "alz" {
  depends_on = [
    azuredevops_git_repository_file.alz,
    azuredevops_git_repository_branch.environment_branches
  ]

  project_id = azuredevops_project.alz.id

  enabled  = true
  blocking = true

  settings {
    allow_squash                  = true
    allow_rebase_and_fast_forward = false
    allow_basic_no_fast_forward   = false
    allow_rebase_with_merge       = false

    # Dynamic scope for each environment branch
    dynamic "scope" {
      for_each = [for env in var.azdo_environments : env.branch_name]
      content {
        repository_id  = azuredevops_git_repository.alz.id
        repository_ref = "refs/heads/${scope.value}"
        match_type     = "Exact"
      }
    }
  }
}

# # All pull requests must pass a build CI pipeline before they can be merged.
# resource "azuredevops_branch_policy_build_validation" "alz" {
#   depends_on = [azuredevops_git_repository_file.alz, azuredevops_git_repository_branch.environment_branches]

#   project_id = azuredevops_project.alz.id

#   enabled  = true
#   blocking = true

#   settings {
#     display_name        = "Terraform Validation"
#     build_definition_id = azuredevops_build_definition.alz["ci"].id
#     valid_duration      = 720

#     # Dynamic scope for each environment branch
#     dynamic "scope" {
#       for_each = toset([for env_name, env_config in var.azdo_environments : env_config.branch_name])
#       content {
#         repository_id  = azuredevops_git_repository.alz.id
#         repository_ref = "refs/heads/${scope.value}"
#         match_type     = "Exact"
#       }
#     }
#   }
# }
