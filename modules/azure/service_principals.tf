# ==============================================================================
# SERVICE PRINCIPAL (APP REGISTRATION) RESOURCES
# ==============================================================================

# Create Azure AD Application
resource "azuread_application" "environment" {
  count = var.create_service_principal ? 1 : 0

  display_name = var.environment_resources.service_principal_display_name

  # Optional: Add more application configuration as needed
  tags = ["terraform", var.project_name, var.environment_name]
}

# Create Service Principal for the Application
resource "azuread_service_principal" "environment" {
  count = var.create_service_principal ? 1 : 0

  client_id                    = azuread_application.environment[0].client_id
  app_role_assignment_required = false

  tags = ["terraform", var.project_name, var.environment_name]
}

# Local variables for service principal selection
locals {
  # Select the appropriate application ID for federated credentials (client_id not object_id)
  application_id              = var.create_service_principal ? azuread_application.environment[0].object_id : data.azuread_application.existing[0].object_id
  service_principal_object_id = var.create_service_principal ? azuread_service_principal.environment[0].object_id : data.azuread_service_principal.existing[0].object_id
}

# Federated identity credential for service principal (handles both new and existing)
resource "azuread_application_federated_identity_credential" "environment" {
  count = (var.create_service_principal || var.import_existing_spn) ? 1 : 0

  application_id = "/applications/${local.application_id}"
  display_name   = "federated-credential-${var.project_name}-${var.environment_name}"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = var.federated_credentials.issuer
  subject        = var.federated_credentials.subject
}

# # Assign Owner role to the service principal on the resource group (handles both new and existing)
# resource "azurerm_role_assignment" "spn_owner" {
#   provider = azurerm.target
#   count    = var.create_service_principal || var.import_existing_spn ? 1 : 0

#   scope                = azurerm_resource_group.rg_devops.id
#   principal_id         = local.service_principal_object_id
#   role_definition_name = "Owner"
# }
