output "user_assigned_managed_identity_client_ids" {
  description = "Client IDs of created managed identities"
  value = { for key, identity in azurerm_user_assigned_identity.alz : key => identity.client_id }
}
