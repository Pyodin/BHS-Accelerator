# 🚀 Azure Terraform Accelerator

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![Azure](https://img.shields.io/badge/azure-%230072C6.svg?style=for-the-badge&logo=microsoftazure&logoColor=white)
![Azure DevOps](https://img.shields.io/badge/Azure%20DevOps-0078D7?style=for-the-badge&logo=azure-devops&logoColor=white)

Bootstrap a complete Azure DevOps environment with secure CI/CD pipelines using Terraform.

**What it creates:**
- Azure infrastructure with managed identities and secure storage backend
- Azure DevOps project with repositories, pipelines, and environments
- Multi-environment CI/CD with automated validation and deployment
- Workload Identity Federation (no secrets stored)

## 🔄 Import Existing Projects

**NEW**: You can now import existing Azure DevOps projects instead of creating new ones! This allows you to:
- Use your existing Azure DevOps project
- Add Infrastructure as Code for repositories, branch policies, and pipelines
- Maintain your existing project structure while gaining Terraform benefits

See [IMPORT_EXISTING_PROJECT.md](./IMPORT_EXISTING_PROJECT.md) for detailed instructions.

## 🔐 Service Connection Options

**NEW**: Choose your preferred authentication method for Azure service connections:
- **Managed Identity** (recommended): Uses Workload Identity Federation - no secrets, automatic token management, more secure
- **App Registration**: Traditional service principal authentication with client secrets

See [SERVICE_CONNECTION_OPTIONS.md](./SERVICE_CONNECTION_OPTIONS.md) for detailed comparison and configuration guide.

**Prerequisites:**
- Azure Subscription
- Azure DevOps Organization  
- Terraform >= 1.6
- Azure CLI
- Git

## Step-by-Step Setup Guide

### Step 1: Clone the Repository

```bash
mkdir my-infrastructure-project && cd my-infrastructure-project
git clone <accelerator-repository-url> accelerator && cd accelerator
```

### Step 2: Configure terraform.tfvars

Create a `terraform.tfvars` file and configure the following options:

#### 2.1 Basic Project Configuration (Required)

```hcl
# Project name - will be used in all resource names
project_name = "my-project"

# Azure region where resources will be deployed
location = "East US"

# Your Azure DevOps organization name
azure_devops_organization_name = "your-org-name"
```

#### 2.2 Environment Configuration (Required - At least one)

You must define at least one environment. Each environment can have different configurations:

**Option A: Single Environment (Development)**
```hcl
environments = {
  dev = {
    subscription_id                  = "11111111-1111-1111-1111-111111111111"
    root_module_folder_relative_path = "."
    approvers                        = []  # No approval required
  }
}
```

**Option B: Multiple Environments**
```hcl
environments = {
  dev = {
    subscription_id                  = "11111111-1111-1111-1111-111111111111"
    root_module_folder_relative_path = "dev"
    approvers                        = []  # No approval required for dev
  }
  staging = {
    subscription_id                  = "22222222-2222-2222-2222-222222222222"
    root_module_folder_relative_path = "staging" 
    approvers                        = ["team-lead@company.com"]  # One approver
  }
  prod = {
    subscription_id                  = "33333333-3333-3333-3333-333333333333"
    root_module_folder_relative_path = "prod"
    approvers                        = [  # Multiple approvers
      "admin1@company.com",
      "admin2@company.com"
    ]
  }
}
```

**Environment Options:**
- `subscription_id`: Azure subscription ID for this environment (required)
- `root_module_folder_relative_path`: Folder name in your terraform project repo (required)
- `approvers`: List of email addresses who must approve deployments (empty list = no approval)

#### 2.3 Azure Subscription Configuration (Optional)

**Option A: Use current Azure CLI subscription (default)**
```hcl
# Don't add bootstrap_subscription_id - uses current az login subscription
```

**Option B: Specify bootstrap subscription**
```hcl
bootstrap_subscription_id = "44444444-4444-4444-4444-444444444444"
```

#### 2.4 Agent Configuration (Optional)

**Option A: Microsoft-hosted agents (default - recommended for most users)**
```hcl
# Don't add any agent configuration - uses Microsoft-hosted agents
```

**Option B: Self-hosted agents (manual setup)**
```hcl
use_self_hosted_agents      = true
self_hosted_agent_pool_name = "MyAgentPool"  # Default: "Default"
```
*Note: You must manually set up and register agents to your pool*

**Option C: Self-hosted container agents (fully automated)**
```hcl
use_self_hosted_agents  = true
create_container_agents = true
agent_count            = 3      # Default: 2, Range: 1-10
agent_cpu_cores        = 2.0    # Default: 1.0, Range: 0.1-4.0
agent_memory_gb        = 4.0    # Default: 2.0, Range: 0.5-14.0
```
*Note: Creates Azure Container Instances with pre-configured agents automatically*

#### 2.5 Branch Protection (Optional)

```hcl
apply_branch_policy = false  # Set to true after initial deployment to enable branch protection
```

#### 2.6 Resource Tags (Optional)

```hcl
tags = {
  Environment = "production"
  Owner       = "platform-team"
  CostCenter  = "IT-001"
}
```

#### 2.7 Complete Example Configuration

```hcl
# Basic Configuration
project_name                   = "my-project"
location                      = "East US"
azure_devops_organization_name = "my-org"

# Environments
environments = {
  dev = {
    subscription_id                  = "11111111-1111-1111-1111-111111111111"
    root_module_folder_relative_path = "dev"
    approvers                        = []
  }
  prod = {
    subscription_id                  = "22222222-2222-2222-2222-222222222222"
    root_module_folder_relative_path = "prod"
    approvers                        = ["admin@company.com"]
  }
}

# Optional configurations
bootstrap_subscription_id = "33333333-3333-3333-3333-333333333333"
apply_branch_policy       = false

# Optional: Container agents
use_self_hosted_agents  = true
create_container_agents = true

# Agent compute configuration
compute_types           = ["azure_container_app"]  # or ["azure_container_instance"] or both
use_private_networking  = false                    # Set to true for private networking

# Container Instance settings (if using azure_container_instance)
container_instance_count  = 2
container_instance_cpu    = 2
container_instance_memory = 4

# Container App settings (if using azure_container_app)
container_app_cpu                      = 1
container_app_memory                   = "2Gi"
container_app_min_execution_count      = 0
container_app_max_execution_count      = 10
container_app_polling_interval_seconds = 30

# Optional: Tags
tags = {
  Environment = "shared"
  Owner       = "platform-team"
}
```

### Step 3: Set Authentication

Set your Azure DevOps Personal Access Token either as an environment variable or in terraform.tfvars:

**Option A: Environment variable (recommended - keeps secrets out of files)**
```bash
export TF_VAR_azure_devops_personal_access_token="your-pat-token"
```

**Option B: In terraform.tfvars file**
```hcl
azure_devops_personal_access_token = "your-pat-token"
```

### Step 4: Deploy

```bash
terraform init
terraform apply
```

### Step 5: Connect Repositories

```bash
# Push accelerator code to templates repository
git remote add azdo https://dev.azure.com/{org}/{project}/_git/templates
git push -u azdo main

# Clone your terraform project repository
cd ..
git clone https://dev.azure.com/{org}/{project}/_git/terraform-{project}
cd terraform-{project}
```

### Step 6: Add Your Infrastructure Code

```bash
# Create folders for each environment and add your Terraform files
mkdir dev prod  # (or whatever environments you configured)

# Add your Terraform files to each environment folder
# Example: dev/main.tf, dev/variables.tf, prod/main.tf, etc.

git add .
git commit -m "Add infrastructure code"
git push origin main
```

### Step 7: (Optional) Enable Branch Protection

After successful deployment, you can enable branch protection:

```bash
cd ../accelerator
# Edit terraform.tfvars: set apply_branch_policy = true
terraform apply
```

## Important Notes

- **First deployment**: Always use `apply_branch_policy = false` initially
- **Agent choice**: Microsoft-hosted agents work for most scenarios
- **Approvers**: Use empty list `[]` for environments that don't need approval
- **Subscriptions**: Can use same or different subscriptions for different environments
- **Backend migration**: The accelerator outputs provide backend configuration for existing projects

## Architecture

- **Azure**: Resource group with storage account + managed identities per environment
- **Azure DevOps**: Project with `templates` repo (this accelerator) and `terraform-{project}` repo (your code)
- **Security**: Workload Identity Federation, no secrets stored
- **Pipelines**: CI (validation) on PRs, CD (deployment) on main branch

