resource "azurerm_resource_group" "burrows" {
  name     = "burrows"
  location = var.location
}

resource "azurerm_static_web_app" "burrows_site" {
  name                = "burrows-site"
  resource_group_name = azurerm_resource_group.burrows.name
  location            = "eastus2"
  sku_tier            = "Free"
  sku_size            = "Free"

  # The repo link and deploy token are created by Azure's GitHub integration
  # and owned by the burrows-manager repo, not Terraform.
  lifecycle {
    ignore_changes = [repository_url, repository_branch, repository_token]
  }
}

resource "azurerm_static_web_app_custom_domain" "burrows" {
  static_web_app_id = azurerm_static_web_app.burrows_site.id
  domain_name       = "burrows.the-lights.co.uk"
  validation_type   = "cname-delegation"

  # Validation only applies when the domain is first added.
  lifecycle {
    ignore_changes = [validation_type]
  }
}
