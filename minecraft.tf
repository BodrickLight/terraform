resource "azurerm_resource_group" "minecraft" {
  name     = "minecraft"
  location = var.minecraft_location
}

# World data lives on an Azure Files share so it survives container restarts.
# ACI can only mount file shares with a storage account key.
resource "azurerm_storage_account" "minecraft" {
  name                     = "stminecraft7d8b"
  resource_group_name      = azurerm_resource_group.minecraft.name
  location                 = azurerm_resource_group.minecraft.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
}

resource "azurerm_storage_share" "world" {
  name               = "world"
  storage_account_id = azurerm_storage_account.minecraft.id
  quota              = 5
}

resource "azurerm_container_group" "minecraft" {
  name                = "minecraft"
  resource_group_name = azurerm_resource_group.minecraft.name
  location            = azurerm_resource_group.minecraft.location
  os_type             = "Linux"
  ip_address_type     = "Public"
  dns_name_label      = "burrows-mc-7d8b"
  restart_policy      = "Always"

  container {
    name   = "bedrock"
    image  = "itzg/minecraft-bedrock-server:latest"
    cpu    = 1
    memory = 2

    # Bedrock's default NetherNet transport: TCP for the signaling handshake,
    # UDP for gameplay.
    ports {
      port     = 19132
      protocol = "TCP"
    }

    ports {
      port     = 19132
      protocol = "UDP"
    }

    environment_variables = {
      EULA             = "TRUE"
      SERVER_NAME      = "Burrows"
      ALLOW_LIST       = "true"
      ALLOW_LIST_USERS = var.minecraft_allow_list_users
    }

    volume {
      name                 = "world"
      mount_path           = "/data"
      share_name           = azurerm_storage_share.world.name
      storage_account_name = azurerm_storage_account.minecraft.name
      storage_account_key  = azurerm_storage_account.minecraft.primary_access_key
    }
  }
}

output "minecraft_address" {
  description = "Address to add in Minecraft Bedrock (port 19132)."
  value       = azurerm_container_group.minecraft.fqdn
}
