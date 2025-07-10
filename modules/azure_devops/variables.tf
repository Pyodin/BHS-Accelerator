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

variable "az_environments" {
  type = map(object({
    environment_name        = string
    service_connection_name = string
    # service_connection_required_templates = list(string)
  }))
} #Todo update the object 

variable "azdo_environments" {
  type = map(object({
    branch_name = string
    approvers   = list(string)
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

# variable "environment_approvers" {
#   description = "Map of environment-specific approvers. Key is environment name, value is list of approver emails."
#   type        = map(list(string))
#   default     = {}
# }

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

# variable "environment_branches" {
#   description = "List of environment names that will have corresponding branches"
#   type        = list(string)
#   default     = []
# }

# variable "repository_branches" {
#   description = "Configuration for repository branches"
#   type = object({
#     default_branch = string
#     branches       = list(string)
#   })
#   default = {
#     default_branch = "main"
#     branches       = ["dev", "prod"]
#   }
# }
