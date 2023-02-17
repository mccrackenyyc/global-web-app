output "dnsdelegation" {
  value = azurerm_dns_zone.gwa_dnszone.name_servers
}