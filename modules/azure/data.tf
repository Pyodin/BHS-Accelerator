# ==============================================================================
# DATA SOURCES FOR SERVICE PRINCIPAL
# ==============================================================================

# Get application details from display name (when importing existing app registration)
data "azuread_application" "existing" {
  count        = var.import_existing_spn ? 1 : 0
  display_name = var.existing_spn_display_name
}

# Get service principal object ID (needed for role assignments)
data "azuread_service_principal" "existing" {
  count     = var.import_existing_spn ? 1 : 0
  client_id = data.azuread_application.existing[0].client_id
}

