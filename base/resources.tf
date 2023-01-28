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

resource "azurerm_storage_container" "gwa_terraform" {
  name                  = "terraform"
  storage_account_name  = azurerm_storage_account.gwa_statefile.name
  container_access_type = "private"
}