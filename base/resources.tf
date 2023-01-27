resource "azurerm_resource_group" "gwa_statefile" {
  name     = "gwa-statefile"
  location = "Canada Central"
}

resource "azurerm_storage_account" "gwa_statefile" {
  name                     = "mccrackenyycgwastatefile"
  resource_group_name      = azurerm_resource_group.gwa_statefile.name
  location                 = azurerm_resource_group.gwa_statefile.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "exampletag"
  }
}