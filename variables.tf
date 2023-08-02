variable "subscription_id" {}
variable "tenant_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "location" {
  description = "The Azure region where resources will be created."
  default     = "East US" # Change this to your desired region
}
variable "vms" {
  type    = list(string)
  default = ["vm1","vm2", "vm3"]
}
variable "env_name" {
  default =  "chavo"
}
