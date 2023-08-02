output "public_ip_addresses" {
  value = values(azurerm_public_ip.public_ip)[*].ip_address
}