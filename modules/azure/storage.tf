module "avm-res-storage-storageaccount" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.6.4"

  depends_on = [azurerm_resource_group.rg_shared]

  name                = replace(var.storage_account_name, "-", "")
  resource_group_name = var.resource_group_name
  location            = var.location

  # Account configuration
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = var.storage_account_replication_type

  # Security configuration
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  public_network_access_enabled   = true
  https_traffic_only_enabled      = true

  # Network configuration
  network_rules = {
    default_action = "Allow"           # Default action for network rules
    bypass         = ["AzureServices"] # Allow Azure services to access the storage account
  }

  # Container configuration
  containers = {
    (var.storage_account_state_container) = {
      name                      = var.storage_account_state_container
      public_access             = "None"
      schema_validation_enabled = false
    }
  }

  # Enable soft delete for blobs and containers
  blob_properties = {
    delete_retention_policy = {
      days    = 7
      enabled = true
    }
  }

  # Enable soft delete for blobs and containers

  # Additional role assignments for created managed identities
  role_assignments = merge(
    # Reader roles for managed identities
    {
      for key, identity in azurerm_user_assigned_identity.alz :
      "Reader_${key}" => {
        principal_id               = identity.principal_id
        role_definition_id_or_name = "Reader"
      }
    },
    # Storage Blob Data Contributor roles for managed identities
    {
      for key, identity in azurerm_user_assigned_identity.alz :
      "StorageBlobDataContributor_${key}" => {
        principal_id               = identity.principal_id
        role_definition_id_or_name = "Storage Blob Data Contributor"
      }
    }
  )

  enable_telemetry = false
  tags             = var.tags
}



