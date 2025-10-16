# ==============================================================================
# DEPLOYMENT SUMMARY
# ==============================================================================

output "deployment_summary" {
  description = "Complete summary of the accelerator deployment"
  value = {
    message = "🎉 Accelerator deployment completed successfully!"

    azure_devops = {
      organization_url     = module.azure_devops.organization_url
      project_name         = var.project_name
      repository_name      = module.azure_devops.repository.name
      repository_web_url   = module.azure_devops.repository.web_url
      repository_clone_url = module.azure_devops.repository.url
    }

    next_steps = [
      "1. Clone your repository: git clone ${module.azure_devops.repository.url}",
      "2. Start developing your infrastructure!"
    ]
  }
}
