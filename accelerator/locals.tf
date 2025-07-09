locals {
  resource_names = {
    # Azure
    resource_group_state    = "rg-${var.project_name}-${var.environment}-state-${var.location}"
    resource_group_identity = "rg-${var.project_name}-${var.environment}-identity-${var.location}"

    storage_account_state           = module.naming.storage_account.name_unique
    storage_account_state_container = "tfstate"

    user_assigned_managed_identity_plan  = "uai-${var.project_name}-${var.environment}-${local.plan_key}"
    user_assigned_managed_identity_apply = "uai-${var.project_name}-${var.environment}-${local.apply_key}"

    # Azure DevOps
    azure_devops_repository                 = "tf-${var.environment}"
    system_environment_plan                 = "${var.project_name}-${var.environment}-plan"
    system_environment_apply                = "${var.project_name}-${var.environment}-apply"
    service_connection_plan                 = "sc-${var.project_name}-${var.environment}-plan"
    service_connection_apply                = "sc-${var.project_name}-${var.environment}-apply"
    federated_credentials_plan              = "fc-${var.project_name}-${var.environment}-plan"
    federated_credentials_apply             = "fc-${var.project_name}-${var.environment}-apply"
    variable_group_name                     = "vg-${var.project_name}-${var.environment}"
    version_control_system_pipeline_name_ci = "01 Azure Landing Zones Continuous Integration"
    version_control_system_pipeline_name_cd = "02 Azure Landing Zones Continuous Delivery"
  }
}

locals {
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
  managed_identities = {
    (local.plan_key)  = local.resource_names.user_assigned_managed_identity_plan
    (local.apply_key) = local.resource_names.user_assigned_managed_identity_apply
  }

  federated_credentials = {
    (local.plan_key) = {
      user_assigned_managed_identity_key = local.plan_key
      federated_credential_subject       = module.azure_devops.subjects[local.plan_key]
      federated_credential_issuer        = module.azure_devops.issuers[local.plan_key]
      federated_credential_name          = local.resource_names.federated_credentials_plan
    }
    (local.apply_key) = {
      user_assigned_managed_identity_key = local.apply_key
      federated_credential_subject       = module.azure_devops.subjects[local.apply_key]
      federated_credential_issuer        = module.azure_devops.issuers[local.apply_key]
      federated_credential_name          = local.resource_names.federated_credentials_apply
    }
  }
}

locals {
  environments = {
    (local.plan_key) = {
      environment_name        = local.resource_names.system_environment_plan
      service_connection_name = local.resource_names.service_connection_plan
    }
    (local.apply_key) = {
      environment_name        = local.resource_names.system_environment_apply
      service_connection_name = local.resource_names.service_connection_apply
    }
  }
}

locals {
  tags = merge(
    {
      "Project"     = var.project_name,
      "Environment" = var.environment,
      "Location"    = var.location
    },
    var.tags
  )
}
