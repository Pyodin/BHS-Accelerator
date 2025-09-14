# ==============================================================================
# DEPLOYMENT SUMMARY
# ==============================================================================

output "deployment_summary" {
  description = "Complete summary of the accelerator deployment"
  value = {
    message = "🎉 Accelerator deployment completed successfully!"

    azure_subscription = {
      id   = data.azurerm_client_config.current.subscription_id
      name = data.azurerm_subscription.current.display_name
    }

    terraform_backend = {
      resource_group_name  = local.resource_names.resource_group_name
      storage_account_name = local.resource_names.storage_account_state
      container_name       = local.resource_names.storage_account_state_container
    }

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

# ==============================================================================
# MANAGED IDENTITIES OUTPUTS
# ==============================================================================

output "managed_identity_client_ids" {
  description = "Client IDs of all managed identities by environment and operation type"
  value       = module.azure.user_assigned_managed_identity_client_ids
}
