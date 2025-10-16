module "avm-res-storage-storageaccount" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.6.4"
  
  providers = {
    azurerm = azurerm.target
  }

  depends_on = [azurerm_resource_group.rg_devops]

  name                = var.environment_resources.storage_account_name
  resource_group_name = var.environment_resources.resource_group_name
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
    (var.environment_resources.storage_account_state_container) = {
      name                      = var.environment_resources.storage_account_state_container
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

  role_assignments = merge(
    # Managed Identity
    var.create_managed_identity ? {
      "storage_contributor_mi" = {
        role_definition_id_or_name = "Storage Blob Data Contributor"
        principal_id               = azurerm_user_assigned_identity.environment[0].principal_id
      }
    } : {},
    # Created Service Principal
    var.create_service_principal ? {
      "storage_contributor_created_spn" = {
        role_definition_id_or_name = "Storage Blob Data Contributor"
        principal_id               = azuread_service_principal.environment[0].object_id
      }
    } : {},
    # Imported Service Principal
    var.import_existing_spn ? {
      "storage_contributor_existing_spn" = {
        role_definition_id_or_name = "Storage Blob Data Contributor"
        principal_id               = data.azuread_service_principal.existing[0].object_id
      }
    } : {}
  )

  enable_telemetry = false
  tags             = var.tags
}



