terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform"
    storage_account_name = "sttfstate7d8b"
    container_name       = "tfstate"
    key                  = "main.tfstate"
    use_azuread_auth     = true
  }
}
