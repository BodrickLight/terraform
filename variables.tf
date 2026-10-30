variable "subscription_id" {
  type        = string
  description = "Azure subscription that holds all managed resources."
  default     = "f08977cd-8daa-4cde-90a6-74099f617449"
}

variable "minecraft_location" {
  type        = string
  description = "Region for the Minecraft server. westeurope rejects new storage accounts on this subscription."
  default     = "uksouth"
}

variable "minecraft_allow_list_users" {
  type        = string
  description = "Comma-separated Xbox gamertags allowed to join. Empty means nobody can."
  default     = "B0drickLight"
}

variable "location" {
  type        = string
  description = "Default region for new resources."
  default     = "westeurope"
}
