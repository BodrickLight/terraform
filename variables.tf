variable "subscription_id" {
  type        = string
  description = "Azure subscription that holds all managed resources."
  default     = "f08977cd-8daa-4cde-90a6-74099f617449"
}

variable "location" {
  type        = string
  description = "Default region for new resources."
  default     = "westeurope"
}
