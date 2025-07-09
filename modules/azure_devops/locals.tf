locals {
  organization_url = startswith(lower(var.organization_name), "https://") || startswith(lower(var.organization_name), "http://") ? var.organization_name : "https://dev.azure.com/${var.organization_name}"
}

locals {
  apply_key = "apply"
}

locals {
  default_branch = "refs/heads/main"
}