module "avm-res-storage-storageaccount" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.6.3"

  name                = var.storage_account_name
  resource_group_name = var.resource_group_state
  location            = var.location

  # Account configuration
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = var.storage_account_replication_type

  # Security configuration
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  public_network_access_enabled   = true
  # public_network_access_enabled   = var.use_private_networking && var.use_self_hosted_agents && !var.allow_storage_access_from_my_ip ? false : true
  https_traffic_only_enabled      = true

  # Network configuration
  # Todo: Consider using private endpoints for enhanced security

  # Container configuration
  containers = {
    (var.storage_account_state_container) = {
      name                      = var.storage_account_state_container
      public_access             = "None"
      schema_validation_enabled = false
    }
  }

  # Additional role assignments
  role_assignments = merge(
    # Reader roles for managed identities
    {
      for key, identity in var.user_assigned_managed_identities :
      "Reader_${key}" => {
        principal_id               = azurerm_user_assigned_identity.alz[key].principal_id
        role_definition_id_or_name = "Reader"
      }
    },
    # Storage Blob Data Contributor roles for managed identities
    {
      for key, identity in var.user_assigned_managed_identities :
      "StorageBlobDataContributor_${key}" => {
        principal_id               = azurerm_user_assigned_identity.alz[key].principal_id
        role_definition_id_or_name = "Storage Blob Data Contributor"
      }
    }
  )

  enable_telemetry = false
  tags = var.tags
}



