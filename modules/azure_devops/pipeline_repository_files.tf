# ==============================================================================
# PIPELINE REPOSITORY FILES MANAGEMENT
# ==============================================================================

# Create files only on feature branch for manual review and merging
# This ensures files are not pushed directly to main branch

# Create feature branch with pipeline files for manual review and merging
resource "azuredevops_git_repository_branch" "pipeline_files_branch" {
  repository_id = azuredevops_git_repository.terraform.id
  name          = "feature/pipeline-updates"
  ref_branch    = azuredevops_git_repository.terraform.default_branch
}

resource "azuredevops_git_repository_file" "pipeline_files_branch" {
  for_each = local.all_pipeline_files

  repository_id       = azuredevops_git_repository.terraform.id
  file                = each.key
  content             = each.value.content
  branch              = "refs/heads/${azuredevops_git_repository_branch.pipeline_files_branch.name}"
  commit_message      = "[skip ci] Add pipeline file: ${each.key}"
  overwrite_on_create = true

  depends_on = [azuredevops_git_repository_branch.pipeline_files_branch]

  lifecycle {
    create_before_destroy = true
    ignore_changes = [commit_message]
  }
} 
