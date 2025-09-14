# ==============================================================================
# AGENT POOLS
# ==============================================================================

# Create self-hosted agent pool if needed
resource "azuredevops_agent_pool" "self_hosted" {
  count = var.pipeline_config.self_hosted_agent ? 1 : 0

  name           = var.self_hosted_agent_pool_name
  auto_provision = false
  auto_update    = true
}

# Grant project access to the agent pool
resource "azuredevops_agent_queue" "self_hosted" {
  count = var.pipeline_config.self_hosted_agent ? 1 : 0

  project_id    = local.project_id
  agent_pool_id = azuredevops_agent_pool.self_hosted[0].id
}
