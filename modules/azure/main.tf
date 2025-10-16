resource "azurerm_resource_group" "rg_devops" {
  provider = azurerm.target
  
  name     = var.environment_resources.resource_group_name
  location = var.location

  tags = var.tags
}
