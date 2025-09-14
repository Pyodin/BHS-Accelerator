# ==============================================================================
# PIPELINE REPOSITORY FILES MANAGEMENT
# ==============================================================================

# Push templated pipeline files to repository
resource "azuredevops_git_repository_file" "pipeline_files" {
  for_each = local.all_pipeline_files

  repository_id       = azuredevops_git_repository.terraform.id
  file                = each.key
  content             = each.value.content
  branch              = azuredevops_git_repository.terraform.default_branch
  commit_message      = "[skip ci] Update pipeline files"
  overwrite_on_create = true

  # Ensure this happens before branch policies are applied
  lifecycle {
    create_before_destroy = true
    ignore_changes = [commit_message]
  }
}


# Todo: Create a new branch and a merge request 