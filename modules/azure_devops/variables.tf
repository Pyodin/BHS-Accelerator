# ==============================================================================
# AZURE DEVOPS ORGANIZATION & PROJECT VARIABLES
# ==============================================================================

variable "organization_name" {
  description = "The name of the Azure DevOps organization"
  type        = string
}

variable "project_name" {
  description = "The name of the Azure DevOps project"
  type        = string
}

variable "import_existing_project" {
  description = "Whether to import an existing Azure DevOps project instead of creating a new one"
  type        = bool
  default     = false
}

variable "existing_project_id" {
  description = "The ID of the existing Azure DevOps project to import (required when import_existing_project is true)"
  type        = string
  default     = ""
}

variable "service_connection_type" {
  description = "Type of authentication for Azure service connections"
  type        = string
  default     = "managed_identity"
  validation {
    condition     = contains(["managed_identity", "app_registration"], var.service_connection_type)
    error_message = "service_connection_type must be either 'managed_identity' or 'app_registration'."
  }
}

# ==============================================================================
# ENVIRONMENT CONFIGURATION VARIABLES
# ==============================================================================

variable "environments" {
  description = "Environment configurations"
  type = map(object({
    approvers                        = list(string)
    root_module_folder_relative_path = string
    subscription_id                  = string
  }))
}

variable "sub_projects" {
  description = "List of sub-projects that will be created under each environment (e.g., network, compute, storage)"
  type        = list(string)
  default     = []
}

variable "managed_identity_client_ids" {
  description = "Map of environment-specific managed identity client IDs"
  type        = map(string)
}

# ==============================================================================
# AZURE BACKEND CONFIGURATION VARIABLES
# ==============================================================================

variable "azure_tenant_id" {
  description = "Azure tenant ID"
  type        = string
}

variable "azure_subscription_id" {
  description = "Azure subscription ID for backend resources"
  type        = string
}

variable "azure_subscription_name" {
  description = "Azure subscription name for backend resources"
  type        = string
}

variable "backend_azure_resource_group_name" {
  description = "Azure Resource Group for terraform backend"
  type        = string
}

variable "backend_azure_storage_account_name" {
  description = "Azure Storage Account for terraform backend"
  type        = string
}

variable "backend_azure_storage_account_container_name" {
  description = "Azure Storage Account Container for terraform backend"
  type        = string
}

# ==============================================================================
# REPOSITORY CONFIGURATION VARIABLES
# ==============================================================================

variable "repository_name" {
  description = "Name of the terraform repository"
  type        = string
}

variable "apply_branch_policy" {
  description = "Whether to apply branch policies to the terraform repository. Note: Set to false for initial deployment, then true for subsequent applies to avoid policy conflicts with pipeline file updates."
  type        = bool
  default     = false
}

variable "min_approvers" {
  description = "Minimum number of required approvers for pull requests"
  type        = number
  default     = 2
}

# ==============================================================================
# PIPELINE CONFIGURATION VARIABLES
# ==============================================================================

variable "pipeline_files_content" {
  description = "Pipeline file content by category (main, templates, helpers)"
  type = object({
    main      = map(string)
    templates = map(string)
    helpers   = map(string)
  })
}

variable "pipeline_config" {
  description = "Pipeline agent and configuration settings"
  type = object({
    agent_pool        = string
    self_hosted_agent = bool
  })
}

variable "self_hosted_agent_pool_name" {
  description = "Name of the self-hosted agent pool to create when using self-hosted agents"
  type        = string
  default     = "Default"
}
