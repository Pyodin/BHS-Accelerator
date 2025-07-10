# ------------------------
# Azure variables
# ------------------------
variable "bootstrap_subscription_id" {
  description = "Azure Subscription ID for the bootstrap resources (e.g. storage account, identities, etc). Leave empty to use the az login subscription"
  type        = string
  default     = ""
  validation {
    condition     = var.bootstrap_subscription_id == "" ? true : can(regex("^[0-9a-fA-F-]{36}$", var.bootstrap_subscription_id))
    error_message = "The bootstrap subscription ID must be a valid GUID"
  }
}

variable "location" {
  description = "The Azure region where resources will be deployed."
  type        = string
}

variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to resources."
  type        = map(string)
  default     = {}
}

# ------------------------
# Azure Devops Variables
# ------------------------

variable "azure_devops_organization_name" {
  description = "The name of the Azure DevOps organization."
  type        = string
}

variable "azure_devops_personal_access_token" {
  description = "The personal access token for Azure DevOps"
  type        = string
  sensitive   = true
}

variable "environments" {
  description = "Configuration for environments including branch names and approvers"
  type = map(object({
    branch_name = string
    approvers   = list(string)
  }))
  default = {
    dev = {
      branch_name = "dev"
      approvers   = []
    }
  }

  validation {
    condition     = length(var.environments) > 0
    error_message = "At least one environment must be specified."
  }
}

variable "default_branch" {
  description = "The default branch for the repository"
  type        = string
  
  validation {
    condition     = contains(keys(var.environments), var.default_branch)
    error_message = "The default branch must be one of the environment keys."
  }
}

variable "root_module_folder_relative_path" {
  type        = string
  description = "The root module folder path"
  default     = "."
}

variable "use_self_hosted_agents" {
  description = "Controls whether to use self-hosted agents for the pipelines"
  type        = bool
  default     = true
}
