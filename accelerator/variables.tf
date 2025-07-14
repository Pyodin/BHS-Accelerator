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

variable "environment" {
  description = "The deployment environment (e.g., dev, test, prod)."
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

variable "use_self_hosted_agents" {
  description = "Controls whether to use self-hosted agents for the pipelines"
  type        = bool
  default     = true
}

variable "apply_approvers" {
  description = "Apply stage approvers to the action / pipeline, must be a list of SPNs separate by a comma (e.g. abcdef@microsoft.com,ghijklm@microsoft.com)"
  type        = list(string)
  default     = []
}

variable "root_module_folder_relative_path" {
  type        = string
  description = "The root module folder path"
  default     = "."
}