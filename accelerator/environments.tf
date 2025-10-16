# ==============================================================================
# ENVIRONMENT CONFIGURATION - MANUAL UPDATES ONLY  
# ==============================================================================
#
# This file contains ONLY the variables you need to manually update when 
# adding new environments. Dynamic computations are handled in locals.tf.
#
# ==============================================================================
# TO ADD A NEW ENVIRONMENT (e.g., "staging"):
# ==============================================================================
#
# 1. UPDATE THIS FILE (2 places below):
#    - Add to `environments` local  
#    - Add to `available_azure_modules` local
#
# 2. ADD PROVIDER IN providers.tf
# 3. ADD MODULE IN main.tf
#
# Everything else is computed automatically!
# ==============================================================================

locals {
  # Complete environment configuration
  environments = {
    dev = {
      root_module_folder_relative_path = "dev"
      subscription_id                  = "5f28cdf6-fa6b-42fa-8f6e-0979598f1794"
      approvers                        = []
    }
    prod = {
      root_module_folder_relative_path = "prod"
      subscription_id                  = "5c12e33d-42ac-4fea-9888-191367e01777"
      approvers                        = []
    }

    # ADD NEW ENVIRONMENTS HERE:
    # staging = {
    #   root_module_folder_relative_path = "staging"
    #   subscription_id                  = "your-staging-subscription-id"
    #   approvers                        = []
    # }
  }
}
