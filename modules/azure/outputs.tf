output "managed_identity_client_id" {
  description = "Client ID of the created managed identity"
  value       = var.create_managed_identity ? azurerm_user_assigned_identity.environment[0].client_id : null
}

output "service_principal_client_id" {
  description = "Client ID of the service principal (created or imported)"
  value = var.create_service_principal ? azuread_application.environment[0].client_id : (
    var.import_existing_spn ? data.azuread_application.existing[0].client_id : null
  )
}

output "service_principal_object_id" {
  description = "Object ID of the service principal (created or imported)"
  value = var.create_service_principal ? azuread_service_principal.environment[0].object_id : (
    var.import_existing_spn ? data.azuread_service_principal.existing[0].object_id : null
  )
}
