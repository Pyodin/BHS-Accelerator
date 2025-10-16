variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be deployed."
  type        = string
}

variable "environment_name" {
  description = "The name of the environment (e.g., dev, prod, staging)."
  type        = string
}

variable "environment_resources" {
  description = "Centralized environment resource configuration"
  type = object({
    resource_group_name                          = string
    storage_account_name                         = string
    storage_account_state_container              = string
    container_registry_name                      = string
    managed_identity_name                        = string
    federated_credential_name                    = string
    service_principal_display_name               = string
    backend_azure_storage_account_name           = string
    backend_azure_storage_account_container_name = string
    subscription_id                              = string
  })
}

# ==============================================================================
# AUTHENTICATION CONFIGURATION
# ==============================================================================

# Managed Identity Configuration
variable "create_managed_identity" {
  description = "Whether to create a managed identity for this environment"
  type        = bool
  default     = false
}

# Service Principal Configuration
variable "create_service_principal" {
  description = "Whether to create a new service principal (app registration) for this environment"
  type        = bool
  default     = false
}

variable "import_existing_spn" {
  description = "Whether to import existing service principals"
  type        = bool
  default     = false
}

# Managed identity and federated credential names are computed in locals.tf

variable "federated_credentials" {
  description = "Federated credentials to create for this environment's managed identity"
  type = object({
    subject = string
    issuer  = string
  })
  default = null
}


# Storage account and container registry names are computed in locals.tf

variable "storage_account_replication_type" {
  description = "The replication type for the storage account"
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_account_replication_type)
    error_message = "Storage account replication type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

variable "tags" {
  description = "A map of tags to assign to resources."
  type        = map(string)
  default     = {}
}

# ==============================================================================
# SERVICE PRINCIPAL CONFIGURATION
# ==============================================================================

variable "existing_spn_display_name" {
  description = "Display name of the existing service principal to import (when import_existing_spn is true)"
  type        = string
  default     = ""
}

# ==============================================================================
# SELF-HOSTED AGENTS CONFIGURATION
# ==============================================================================

variable "create_self_hosted_agents" {
  description = "Whether to create Azure Container Instances for self-hosted Azure DevOps agents"
  type        = bool
  default     = false
}

variable "azure_devops_organization_url" {
  description = "Azure DevOps organization URL for agent registration"
  type        = string
  default     = ""
}

variable "agent_pool_name" {
  description = "Name of the agent pool for agent registration"
  type        = string
  default     = ""
}

variable "azure_devops_agent_pat" {
  description = "Personal Access Token for Azure DevOps agent registration"
  type        = string
  sensitive   = true
  default     = ""
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
