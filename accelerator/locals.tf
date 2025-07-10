locals {
  # Stage definitions
  plan_key  = "plan"
  apply_key = "apply"
}

locals {
  ci_file_name          = "ci.yaml"
  cd_file_name          = "cd.yaml"
  ci_template_file_name = "ci-template.yaml"
  cd_template_file_name = "cd-template.yaml"
}

locals {
  # All resource name patterns - centralized naming logic
  resource_names = {
    # Infrastructure
    resource_group = "rg-${var.project_name}-${var.location}"

    storage_account_state           = module.naming.storage_account.name_unique
    storage_account_state_container = "tfstate"

    # Azure DevOps
    azure_devops_repository                 = "tf-${var.project_name}"
    variable_group_name                     = "vg-${var.project_name}-shared" #Todo: one vg/env
    version_control_system_pipeline_name_ci = "01 ${var.project_name} Continuous Integration"
    version_control_system_pipeline_name_cd = "02 ${var.project_name} Continuous Delivery"
    # version_control_system_agent_pool       = "ap-${var.project_name}"
  }

  # Primary structure - flat map for direct compatibility with all modules
  environments = merge([
    for env_name, env_config in var.environments : {
      "${env_name}-${local.plan_key}" = {
        environment_name               = "${var.project_name}-${env_name}-${local.plan_key}"
        service_connection_name        = "sc-${var.project_name}-${env_name}-${local.plan_key}"
        user_assigned_managed_identity = "uai-${var.project_name}-${env_name}-${local.plan_key}"
        federated_credentials_name     = "fc-${var.project_name}-${env_name}-${local.plan_key}"
        # branch_name                    = "refs/heads/${env_config.branch_name}"
        # approvers                      = env_config.approvers
      }
      "${env_name}-${local.apply_key}" = {
        environment_name               = "${var.project_name}-${env_name}-${local.apply_key}"
        service_connection_name        = "sc-${var.project_name}-${env_name}-${local.apply_key}"
        user_assigned_managed_identity = "uai-${var.project_name}-${env_name}-${local.apply_key}"
        federated_credentials_name     = "fc-${var.project_name}-${env_name}-${local.apply_key}"
        # branch_name                    = "refs/heads/${env_config.branch_name}"
        # approvers                      = env_config.approvers
      }
    }
  ]...)

  # Derived locals for module compatibility 
  managed_identities = {
    for key, env in local.environments : key => env.user_assigned_managed_identity
  }

  federated_credentials = merge([
    for key, env in local.environments : {
      key = {
        user_assigned_managed_identity_key = key
        federated_credential_subject       = module.azure_devops.subjects[key]
        federated_credential_issuer        = module.azure_devops.issuers[key]
        federated_credential_name          = env.federated_credentials_name
      }
    }
  ]...)

  tags = merge(
    {
      "Project"  = var.project_name,
      "Location" = var.location
    },
    var.tags
  )
}
