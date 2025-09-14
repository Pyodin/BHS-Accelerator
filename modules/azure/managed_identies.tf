# Create managed identities for all environments
resource "azurerm_user_assigned_identity" "alz" {
  for_each = var.user_assigned_managed_identities

  location            = var.location
  name                = each.value
  resource_group_name = azurerm_resource_group.rg_shared.name

  tags = var.tags
}

resource "azurerm_federated_identity_credential" "alz" {
  for_each = var.federated_credentials

  name                = each.value.federated_credential_name
  resource_group_name = azurerm_resource_group.rg_shared.name

  audience  = ["api://AzureADTokenExchange"]
  issuer    = each.value.federated_credential_issuer
  parent_id = azurerm_user_assigned_identity.alz[each.value.user_assigned_managed_identity_key].id
  subject   = each.value.federated_credential_subject
}

# resource "azurerm_role_assignment" "owner" {
#   for_each             = var.user_assigned_managed_identities

#   scope                = azurerm_resource_group.rg_shared.id
#   principal_id         = azurerm_user_assigned_identity.alz[each.key].principal_id
#   role_definition_name = "Owner"
# }
