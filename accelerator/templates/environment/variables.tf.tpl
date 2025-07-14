variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "${project_name}"
}

variable "environment" {
  description = "The environment name"
  type        = string
  default     = "${environment}"
}

variable "location" {
  description = "The Azure region where resources will be deployed"
  type        = string
  default     = "francecentral"
}

variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default = {
    Environment = "${environment}"
    Project     = "${project_name}"
    ManagedBy   = "Terraform"
  }
}
