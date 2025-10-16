# Create one managed identity for this environment
resource "azurerm_user_assigned_identity" "environment" {
  provider = azurerm.target
  count    = var.create_managed_identity ? 1 : 0

  location            = var.location
  name                = var.environment_resources.managed_identity_name
  resource_group_name = azurerm_resource_group.rg_devops.name

  tags = var.tags
}

resource "azurerm_federated_identity_credential" "environment" {
  provider = azurerm.target
  count    = var.create_managed_identity ? 1 : 0

  name                = var.environment_resources.federated_credential_name
  resource_group_name = azurerm_resource_group.rg_devops.name

  audience  = ["api://AzureADTokenExchange"]
  issuer    = var.federated_credentials.issuer
  parent_id = azurerm_user_assigned_identity.environment[0].id
  subject   = var.federated_credentials.subject
}

resource "azurerm_role_assignment" "owner" {
  provider = azurerm.target
  count    = var.create_managed_identity ? 1 : 0

  scope                = azurerm_resource_group.rg_devops.id
  principal_id         = azurerm_user_assigned_identity.environment[0].principal_id
  role_definition_name = "Owner"
}
