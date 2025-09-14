locals {
  # ==============================================================================
  # PIPELINE TEMPLATE FILE CONTENT
  # ==============================================================================

  # All pipeline files organized by category for easy management
  pipeline_files_content = {
    # Main pipeline files (environment-specific)
    main = {
      "ci.yaml" = file("pipelines/ci.yaml")
      "cd.yaml" = file("pipelines/cd.yaml")
    }

    # Reusable templates (shared across environments)
    templates = {
      "ci-template.yaml" = file("pipelines/templates/ci-template.yaml")
      "cd-template.yaml" = file("pipelines/templates/cd-template.yaml")
    }

    # Helper files (shared utilities)
    helpers = {
      "terraform-apply.yaml"     = file("pipelines/helpers/terraform-apply.yaml")
      "terraform-init.yaml"      = file("pipelines/helpers/terraform-init.yaml")
      "terraform-installer.yaml" = file("pipelines/helpers/terraform-installer.yaml")
      "terraform-plan.yaml"      = file("pipelines/helpers/terraform-plan.yaml")
    }
  }
}
