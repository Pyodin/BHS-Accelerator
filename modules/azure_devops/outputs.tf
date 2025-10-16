# ==============================================================================
# CORE AZURE DEVOPS OUTPUTS
# ==============================================================================

output "organization_url" {
  description = "The Azure DevOps organization URL"
  value       = local.organization_url
}

output "project" {
  description = "Azure DevOps project information"
  value = {
    name = local.project_name
    id   = local.project_id
  }
}

output "repository" {
  description = "Terraform repository information"
  value = {
    name           = azuredevops_git_repository.terraform.name
    web_url        = azuredevops_git_repository.terraform.web_url
    url            = azuredevops_git_repository.terraform.remote_url
    default_branch = azuredevops_git_repository.terraform.default_branch
  }
}

# ==============================================================================
# WORKLOAD IDENTITY FEDERATION OUTPUTS
# ==============================================================================

output "subjects" {
  description = "OIDC subjects for workload identity federation, per environment"
  value = {
    for k, v in local.service_connections_ref : k => v.workload_identity_federation_subject
  }
}

output "issuers" {
  description = "OIDC issuers for workload identity federation, per environment"
  value = {
    for k, v in local.service_connections_ref : k => v.workload_identity_federation_issuer
  }
}

# ==============================================================================
# ENVIRONMENT-SPECIFIC OUTPUTS
# ==============================================================================

output "environments" {
  description = "Created environments per environment config"
  value = {
    for k, v in azuredevops_environment.environment : k => {
      id   = v.id
      name = v.name
    }
  }
}

output "service_connections" {
  description = "Created service connections per environment"
  value = {
    for k, v in local.service_connections_ref : k => {
      id   = v.id
      name = v.service_endpoint_name
    }
  }
}

output "pipelines" {
  description = "Created pipelines per deployment unit"
  value = {
    for unit_key, unit in local.deployment_units : unit_key => {
      ci = {
        id   = azuredevops_build_definition.ci_pipeline[unit_key].id
        name = azuredevops_build_definition.ci_pipeline[unit_key].name
      }
      cd = {
        id   = azuredevops_build_definition.cd_pipeline[unit_key].id
        name = azuredevops_build_definition.cd_pipeline[unit_key].name
      }
    }
  }
}

output "variable_groups" {
  description = "Created variable groups per environment"
  value = {
    for k, v in azuredevops_variable_group.pipeline : k => {
      id   = v.id
      name = v.name
    }
  }
}

output "approvers_groups" {
  description = "Created approvers groups per environment (only for environments with approvers)"
  value = {
    for k, v in azuredevops_group.approvers : k => {
      id        = v.id
      name      = v.display_name
      origin_id = v.origin_id
    }
  }
}

# ==============================================================================
# PIPELINE FILES OUTPUT
# ==============================================================================

output "pipeline_files" {
  description = "Pipeline files that were created in the repository"
  value = {
    for key, file in azuredevops_git_repository_file.pipeline_files_branch : key => {
      file_path = file.file
      content   = file.content
    }
  }
}

# ==============================================================================
# AGENT POOL OUTPUTS
# ==============================================================================

output "agent_pool_id" {
  description = "ID of the created self-hosted agent pool (if created)"
  value       = var.pipeline_config.self_hosted_agent ? azuredevops_agent_pool.self_hosted[0].id : null
}

output "agent_pool_name" {
  description = "Name of the agent pool being used"
  value       = var.pipeline_config.self_hosted_agent ? var.self_hosted_agent_pool_name : "Azure Pipelines"
}

output "agent_queue_id" {
  description = "ID of the agent queue in the project (if self-hosted)"
  value       = var.pipeline_config.self_hosted_agent ? azuredevops_agent_queue.self_hosted[0].id : null
}
