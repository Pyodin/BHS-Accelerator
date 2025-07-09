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

## What Gets Created

- **Azure Resources**: Resource groups, storage account (with AVM), managed identities
- **Azure DevOps**: Project, Git repository, CI/CD pipelines, service connections, environments
- **Security**: Workload identity federation, branch policies, approval gates, exclusive locks

## Customization

- **Add pipelines**: Create YAML in `pipelines/`, reference in `locals.files.tf`
- **Extend Azure resources**: Modify `modules/azure/`
- **Adjust policies**: Edit `modules/azure_devops/repository_module.tf`

## Tags

`terraform` `azure` `devops` `infrastructure-as-code` `ci-cd` `managed-identity` `azure-verified-modules` `accelerator`
