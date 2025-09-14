resource "azurerm_resource_group" "rg_shared" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}
