# ==============================================================================
# AZURE DEVOPS ENVIRONMENTS
# ==============================================================================

# Create environments for each environment configuration
resource "azuredevops_environment" "environment" {
  for_each = var.environments

  project_id = local.project_id
  name       = "${var.project_name}-${each.key}"
}
