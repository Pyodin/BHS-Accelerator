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



variable "sub_projects" {
  description = "List of sub-projects that will be created under each environment (e.g., network, compute, storage)"
  type        = list(string)
  default     = []
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

variable "import_existing_azure_devops_project" {
  description = "Whether to import an existing Azure DevOps project instead of creating a new one. When true, the project with the specified project_name must already exist in the organization."
  type        = bool
  default     = false
}

variable "existing_azure_devops_project_id" {
  description = "The ID of the existing Azure DevOps project to import. Required when import_existing_azure_devops_project is true. You can find this in the project settings URL."
  type        = string
  default     = ""
  validation {
    condition     = var.import_existing_azure_devops_project == false || (var.import_existing_azure_devops_project == true && var.existing_azure_devops_project_id != "")
    error_message = "existing_azure_devops_project_id must be provided when import_existing_azure_devops_project is true."
  }
}

variable "apply_branch_policy" {
  description = "Whether to apply branch policies to the repository."
  type        = bool
}





variable "service_connection_type" {
  description = "Type of authentication for Azure service connections. 'managed_identity' uses Workload Identity Federation (recommended), 'app_registration' uses traditional service principal with secrets."
  type        = string
  default     = "managed_identity"
  validation {
    condition     = contains(["managed_identity", "app_registration"], var.service_connection_type)
    error_message = "service_connection_type must be either 'managed_identity' or 'app_registration'."
  }
}

variable "import_existing_spn" {
  description = "Whether to import existing service principals (only applicable when service_connection_type is 'app_registration')"
  type        = bool
  default     = false
}

variable "existing_service_principals" {
  description = "Existing service principals configuration for workload identity federation (when import_existing_spn is true)"
  type = map(object({
    display_name = string # Application Display Name
  }))
  default = {}
}

variable "min_approvers" {
  description = "Minimum number of required approvers for environment deployments."
  type        = number
  default     = 1

  validation {
    condition     = var.min_approvers >= 1 && var.min_approvers <= 10
    error_message = "min_approvers must be between 1 and 10."
  }
}

# ==============================================================================
# SELF-HOSTED AGENTS CONFIGURATION
# ==============================================================================
variable "use_self_hosted_agents" {
  description = "Controls whether to use self-hosted agents for the pipelines"
  type        = bool
  default     = false
}

variable "self_hosted_agent_pool_name" {
  description = "Name of the self-hosted agent pool to use when use_self_hosted_agents is true"
  type        = string
  default     = "Default"
}

variable "create_container_agents" {
  description = "Create Azure Container Instances for self-hosted agents (when use_self_hosted_agents is true)"
  type        = bool
  default     = false
}

variable "use_private_networking" {
  description = "Whether to use private networking for the agents"
  type        = bool
  default     = false
}

variable "compute_types" {
  description = "The types of compute to use. Allowed values are 'azure_container_app' and 'azure_container_instance'"
  type        = set(string)
  default     = ["azure_container_app"]

  validation {
    condition = alltrue([
      for compute_type in var.compute_types : contains(["azure_container_app", "azure_container_instance"], compute_type)
    ])
    error_message = "Compute types must be 'azure_container_app' or 'azure_container_instance'."
  }
}

variable "container_instance_count" {
  description = "The number of container instances to create"
  type        = number
  default     = 2

  validation {
    condition     = var.container_instance_count >= 1 && var.container_instance_count <= 10
    error_message = "Container instance count must be between 1 and 10."
  }
}

variable "container_instance_cpu" {
  description = "The CPU value for the container instance"
  type        = number
  default     = 2

  validation {
    condition     = var.container_instance_cpu >= 0.5 && var.container_instance_cpu <= 8
    error_message = "Container instance CPU must be between 0.5 and 8."
  }
}

variable "container_instance_memory" {
  description = "The memory value for the container instance in GB"
  type        = number
  default     = 4

  validation {
    condition     = var.container_instance_memory >= 1 && var.container_instance_memory <= 32
    error_message = "Container instance memory must be between 1 and 32 GB."
  }
}

variable "container_app_cpu" {
  description = "Required CPU in cores for container app, e.g. 0.5"
  type        = number
  default     = 1

  validation {
    condition     = var.container_app_cpu >= 0.25 && var.container_app_cpu <= 8
    error_message = "Container app CPU must be between 0.25 and 8."
  }
}

variable "container_app_memory" {
  description = "Required memory for container app, e.g. '2Gi'"
  type        = string
  default     = "2Gi"

  validation {
    condition     = can(regex("^[0-9]+(Mi|Gi)$", var.container_app_memory))
    error_message = "Container app memory must be in format like '2Gi' or '512Mi'."
  }
}

variable "container_app_min_execution_count" {
  description = "The minimum number of executions (jobs) to spawn per polling interval"
  type        = number
  default     = 0

  validation {
    condition     = var.container_app_min_execution_count >= 0 && var.container_app_min_execution_count <= 100
    error_message = "Container app min execution count must be between 0 and 100."
  }
}

variable "container_app_max_execution_count" {
  description = "The maximum number of executions (jobs) to spawn per polling interval"
  type        = number
  default     = 10

  validation {
    condition     = var.container_app_max_execution_count >= 1 && var.container_app_max_execution_count <= 1000
    error_message = "Container app max execution count must be between 1 and 1000."
  }
}

variable "container_app_polling_interval_seconds" {
  description = "How often should the pipeline queue be checked for new events, in seconds"
  type        = number
  default     = 30

  validation {
    condition     = var.container_app_polling_interval_seconds >= 10 && var.container_app_polling_interval_seconds <= 300
    error_message = "Container app polling interval must be between 10 and 300 seconds."
  }
}
