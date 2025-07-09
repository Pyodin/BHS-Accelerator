# Azure Terraform Accelerator

Bootstrap Terraform projects on Azure with enterprise-grade DevOps practices in minutes.

## Overview

Automates the creation of a complete Azure DevOps environment for Terraform projects with security, governance, and CI/CD best practices built-in.

## Features

- **🔐 Secure Authentication** - Workload Identity Federation with managed identities (no secrets)
- **🏗️ Infrastructure Ready** - Storage account for Terraform state with Azure Verified Modules
- **📚 Git Management** - Repository with branch policies and automated file population
- **🚀 CI/CD Pipelines** - Multi-environment deployment with approvals and validations
- **🛡️ Governance** - Approval workflows, exclusive locks, and required templates

## Resources Created

### Azure Resources
- **Resource Groups** - Separate groups for identity and state management
- **User-Assigned Managed Identities** - Plan and Apply identities with federated credentials
- **Storage Account** - Terraform state backend with AVM security configuration
- **Storage Container** - Blob container for tfstate files with private access

### Azure DevOps Resources
- **Project** - DevOps project container
- **Git Repository** - Source code repository with automated file population
- **Service Connections** - Workload identity federation for secure Azure access
- **Environments** - Plan and Apply environments with approval gates
- **Build Pipelines** - CI/CD pipelines for Terraform validation and deployment
- **Branch Policies** - Code review requirements, merge restrictions, build validation
- **Variable Groups** - Centralized configuration for pipeline variables


## Quick Start

**Prerequisites:** Azure subscription, Azure DevOps organization, Terraform >= 1.0

1. **Configure variables** - Create `accelerator/terraform.tfvars`:
```hcl
location                           = "East US"
project_name                       = "my-project"
environment                        = "dev"
azure_devops_organization_name     = "your-org"
azure_devops_personal_access_token = "your-pat"
apply_approvers                    = ["user@company.com"]
```

2. **Deploy**:
```bash
cd accelerator
terraform init && terraform apply
```

3. **Result**: Complete Azure DevOps project with Git repo, pipelines, and secure state backend.

## Configuration

| Variable | Description | Required |
|----------|-------------|----------|
| `project_name` | Project identifier | ✅ |
| `environment` | Environment (dev/test/prod) | ✅ |
| `location` | Azure region | ✅ |
| `azure_devops_organization_name` | DevOps organization | ✅ |
| `azure_devops_personal_access_token` | PAT for DevOps access | ✅ |
| `apply_approvers` | Production approvers | ❌ |
| `tags` | Resource tags | ❌ |

## Customization

- **Add pipelines**: Create YAML in `pipelines/`, reference in `locals.files.tf`
- **Extend Azure resources**: Modify `modules/azure/`
- **Adjust policies**: Edit `modules/azure_devops/repository_module.tf`

## Tags

`terraform` `azure` `devops` `infrastructure-as-code` `ci-cd` `managed-identity` `azure-verified-modules` `accelerator`
