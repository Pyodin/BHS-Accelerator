resource "azurerm_resource_group" "rg_identity" {
  name     = "rg-${var.project_name}-${var.environment}-identity-${var.location}"
  location = var.location

  tags     = local.tags
}

resource "azurerm_resource_group" "rg_state" {
  name     = "rg-${var.project_name}-${var.environment}-state-${var.location}"
  location = var.location

  tags     = local.tags
}