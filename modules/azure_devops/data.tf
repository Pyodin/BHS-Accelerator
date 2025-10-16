# ==============================================================================
# DATA SOURCES FOR SERVICE PRINCIPALS
# ==============================================================================

# Get application details from client ID (when using app registration)
data "azuread_application" "spn" {
  for_each  = var.service_principal_client_ids
  client_id = each.value
}