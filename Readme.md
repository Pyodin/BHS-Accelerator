# Azure Terraform Accelerator

Bootstrap Terraform projects on Azure with enterprise-grade DevOps practices in minutes.

## Overview

Automates the creation of a complete Azure DevOps environment for Terraform projects with security, governance, and CI/CD best practices built-in.

## Features

- **🔐 Secure Authentication** - Workload Identity Federation with managed identities (no secrets)
- **🏗️ Infrastructure Ready** - Storage account for Terraform state with Azure Verified Modules
- **📚 Git Management** - Repository with environment-specific branches and automated file population
- **🚀 CI/CD Pipelines** - Multi-environment deployment with branch-specific configurations
- **🛡️ Governance** - Environment-specific approval workflows and branch policies
- **🎯 Centralized Configuration** - Single source of truth for environment settings

## Resources Created

### Azure Resources
- **Resource Group** - Single resource group for all Azure resources (identity and state management)
- **User-Assigned Managed Identities** - Plan and Apply identities per environment with federated credentials
- **Storage Account** - Terraform state backend with AVM security configuration
- **Storage Container** - Blob container for tfstate files with private access

### Azure DevOps Resources
- **Project** - DevOps project container
- **Git Repository** - Source code repository with environment-specific branches
- **Service Connections** - Workload identity federation for secure Azure access (plan/apply per environment)
- **Environments** - Plan and Apply environments per branch with approval gates
- **Build Pipelines** - CI/CD pipelines with environment-specific configurations
- **Branch Policies** - Environment-specific code review requirements and build validation
- **Variable Groups** - Centralized configuration for pipeline variables
- **Pipeline Files** - Environment-specific pipeline YAML files deployed to each branch


## Quick Start

**Prerequisites:** Azure subscription, Azure DevOps organization, Terraform >= 1.0

1. **Configure variables** - Create `accelerator/terraform.tfvars`:
```hcl
# Azure 
bootstrap_subscription_id = "your-subscription-id"
location                  = "francecentral"
project_name              = "my-project"

# Environment configuration with branch names and approvers
environments = {
  dev = {
    branch_name = "dev"
    approvers   = []  # No approvers for dev
  }
  prod = {
    branch_name = "prod"
    approvers   = ["user1@company.com", "user2@company.com"]  # Prod requires approval
  }
}

default_branch = "dev"

tags = {
  owner      = "your-name"
  created_by = "Terraform"
}

# Azure DevOps
azure_devops_organization_name = "your-org"
use_self_hosted_agents         = false
```

2. **Set Azure DevOps PAT** (via environment variable):
```bash
export AZDO_PERSONAL_ACCESS_TOKEN="your-pat"
```

3. **Deploy**:
```bash
cd accelerator
terraform init && terraform apply
```

4. **Result**: Complete Azure DevOps project with Git repo, environment-specific branches, pipelines with branch-specific configurations, and secure state backend.

## Configuration

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `project_name` | Project identifier used for resource naming | ✅ | - |
| `location` | Azure region for resource deployment | ✅ | - |
| `environments` | Map of environments with branch names and approvers | ✅ | `{ dev = { branch_name = "dev", approvers = [] } }` |
| `default_branch` | Default branch for the repository (must be an environment key) | ✅ | `"dev"` |
| `azure_devops_organization_name` | Azure DevOps organization name | ✅ | - |
| `azure_devops_personal_access_token` | PAT for Azure DevOps access (can be set via environment variable) | ✅ | - |
| `bootstrap_subscription_id` | Azure subscription ID (uses az login if empty) | ❌ | `""` |
| `use_self_hosted_agents` | Use self-hosted agents instead of Microsoft-hosted | ❌ | `true` |
| `root_module_folder_relative_path` | Root module folder path | ❌ | `"."` |
| `tags` | Resource tags | ❌ | `{}` |

## Customization

- **Add environments**: Extend the `environments` variable in `terraform.tfvars`
- **Modify pipelines**: Edit YAML templates in `pipelines/templates/` and main files in `pipelines/main/`
- **Extend Azure resources**: Modify `modules/azure/` for additional infrastructure
- **Adjust branch policies**: Edit `modules/azure_devops/repository_module.tf`
- **Customize approvers**: Update the `approvers` list for each environment

## Environment Configuration

The accelerator uses a centralized environment configuration approach where all environment settings are defined in a single `environments` variable:

```hcl
environments = {
  dev = {
    branch_name = "dev"        # Git branch name for this environment
    approvers   = []           # List of required approvers (empty = no approval required)
  }
  prod = {
    branch_name = "prod"
    approvers   = ["user@company.com"]  # Production requires approval
  }
}
```

**Key Benefits:**
- **Single Source of Truth**: All environment configuration in one place
- **DRY Principle**: No duplication of environment-related settings
- **Automatic Resource Creation**: Automatically creates plan/apply environments, service connections, and managed identities
- **Branch-Specific Pipelines**: Each branch gets customized pipeline files with environment-specific settings

**Generated Resources Per Environment:**
- `{project}-{env}-plan` and `{project}-{env}-apply` environments
- `sc-{project}-{env}-plan` and `sc-{project}-{env}-apply` service connections  
- User-assigned managed identities with federated credentials
- Environment-specific pipeline files deployed to each branch

## Tags

`terraform` `azure` `devops` `infrastructure-as-code` `ci-cd` `managed-identity` `azure-verified-modules` `accelerator`
