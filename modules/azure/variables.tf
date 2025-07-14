variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "environment" {
  description = "The deployment environment (e.g., dev, test, prod)."
  type        = string
}

variable "location" {
    description = "The Azure region where resources will be deployed."
    type        = string
}

variable "resource_group_identity" {
  description = "The name of the user-assigned managed identity for the resource group."
  type        = string
}

variable "user_assigned_managed_identities" {
  type = map(string)
}

variable "federated_credentials" {
  type = map(object({
    user_assigned_managed_identity_key = string
    federated_credential_subject       = string
    federated_credential_issuer        = string
    federated_credential_name          = string
  }))
  default = {}
}


variable "resource_group_state" {
  description = "The name of the resource group used for state management."
  type        = string
}

variable "storage_account_name" {
  description = "The name of the Azure Storage Account used for backend state."
  type        = string
}

variable "storage_account_state_container" {
  description = "The name of the Azure Storage Account container used for backend state."
  type        = string
}

variable "storage_account_replication_type" {
  description = "The replication type for the storage account"
  type        = string
  default     = "LRS"
  
  validation {
    condition = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_account_replication_type)
    error_message = "Storage account replication type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

variable "additional_role_assignment_principal_ids" {
  description = "Additional principal IDs to assign roles to the storage account"
  type        = map(string)
  default     = {}
}


variable "tags" {
    description = "A map of tags to assign to resources."
    type        = map(string)
    default     = {}
}
