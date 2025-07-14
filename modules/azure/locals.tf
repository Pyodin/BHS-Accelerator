locals {
  audience = "api://AzureADTokenExchange"
}

locals {
  tags = merge(
    {
      module = "azure"
    },
    var.tags
  )
}
