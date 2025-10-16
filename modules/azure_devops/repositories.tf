# Create the terraform repository
resource "azuredevops_git_repository" "terraform" {
  project_id     = local.project_id
  name           = var.repository_name
  default_branch = local.default_branch

  initialization {
    init_type = "Clean"
  }
}

# Branch policies - minimum reviewers 
resource "azuredevops_branch_policy_min_reviewers" "terraform" {

  depends_on = [
    azuredevops_git_repository_file.pipeline_files_branch,
    azuredevops_build_definition.ci_pipeline
  ]

  project_id = local.project_id
  enabled    = var.apply_branch_policy
  blocking   = true

  settings {
    reviewer_count                         = var.min_approvers
    submitter_can_vote                     = true
    last_pusher_cannot_approve             = false
    allow_completion_with_rejects_or_waits = false
    on_push_reset_approved_votes           = true

    scope {
      repository_id  = azuredevops_git_repository.terraform.id
      repository_ref = azuredevops_git_repository.terraform.default_branch
      match_type     = "Exact"
    }
  }
}

# Branch policies - merge types 
resource "azuredevops_branch_policy_merge_types" "terraform" {

  depends_on = [
    azuredevops_git_repository_file.pipeline_files_branch,
    azuredevops_build_definition.ci_pipeline
  ]

  project_id = local.project_id
  enabled    = var.apply_branch_policy
  blocking   = true

  settings {
    allow_squash = true

    scope {
      repository_id  = azuredevops_git_repository.terraform.id
      repository_ref = azuredevops_git_repository.terraform.default_branch
      match_type     = "Exact"
    }
  }
}

# Build validation policies for all deployment units
resource "azuredevops_branch_policy_build_validation" "deployment_validation" {
  for_each = local.deployment_units

  depends_on = [
    azuredevops_git_repository_file.pipeline_files_branch,
    azuredevops_build_definition.ci_pipeline
  ]

  project_id = local.project_id
  enabled    = var.apply_branch_policy
  blocking   = true

  settings {
    display_name        = "${title(each.value.display_name)} CI Validation"
    build_definition_id = azuredevops_build_definition.ci_pipeline[each.key].id
    valid_duration      = 720
    filename_patterns   = [each.value.filename_pattern]

    scope {
      repository_id  = azuredevops_git_repository.terraform.id
      repository_ref = azuredevops_git_repository.terraform.default_branch
      match_type     = "Exact"
    }
  }
}
