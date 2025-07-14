variable "organization_name" {
    description = "The name of the Azure DevOps organization."
    type        = string
}

variable "project_name" {
    description = "The name of the Azure DevOps project."
    type        = string
}

variable "use_self_hosted_agents" {
  type = bool
}

variable "environments" {
  type = map(object({
    environment_name                      = string
    service_connection_name               = string
    # service_connection_required_templates = list(string)
  }))
}

variable "backend_azure_resource_group_name" {
  description = "The name of the Azure Resource Group used for the backend."
  type        = string
}

variable "backend_azure_storage_account_name" {
  description = "The name of the Azure Storage Account used for the backend."
  type        = string
}

variable "backend_azure_storage_account_container_name" {
  description = "The name of the Azure Storage Account Container used for the backend."
  type        = string
}

variable "managed_identity_client_ids" {
  type = map(string)
}

variable "azure_tenant_id" {
  type = string
}

variable "azure_subscription_id" {
  type = string
}

variable "azure_subscription_name" {
  type = string
}

variable "repository_name" {
  type = string
}

variable "approvers" {
  type = list(string)
}

variable "variable_group_name" {
  description = "The name of the Azure DevOps variable group."
  type        = string
}

variable "pipelines" {
  type = map(object({
    pipeline_name           = string
    pipeline_file_name      = string
    environment_keys        = list(string)
    service_connection_keys = list(string)
  }))
}

variable "repository_files" {
  type = map(object({
    content = string
  }))
}
