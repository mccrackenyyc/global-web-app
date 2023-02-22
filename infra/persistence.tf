resource "azurerm_resource_group" "gwa_sql_rg" {
  for_each = local.regions
  name     = "gwa-sql-rg-${each.key}-${var.env_name}"
  location = each.value.longform

  tags = {
    tag = var.exampletag
  }
}

resource "azurerm_storage_account" "gwa_sql_logs" {
  for_each                 = local.regions
  name                     = "gwasqllogs${each.key}${var.env_name}"
  resource_group_name      = azurerm_resource_group.gwa_sql_rg[each.key].name
  location                 = azurerm_resource_group.gwa_sql_rg[each.key].location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    tag = var.exampletag
  }
}

resource "azurerm_mssql_server" "gwa_sql_server" {
  for_each            = local.regions
  name                = "gwa-sql-server-${each.key}-${var.env_name}"
  resource_group_name = azurerm_resource_group.gwa_sql_rg[each.key].name
  location            = azurerm_resource_group.gwa_sql_rg[each.key].location
  version             = "12.0"
  azuread_administrator {
    azuread_authentication_only = true
    login_username              = var.admin_upn
    object_id                   = data.azuread_user.admin.object_id
  }
  minimum_tls_version = "1.2"

  tags = {
    tag = var.exampletag
  }
}

resource "azurerm_mssql_database" "gwa_sql_database" {
  name           = "gwa-sql-database-${var.env_name}"
  server_id      = azurerm_mssql_server.gwa_sql_server["cc"].id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb    = 5
  read_scale     = true
  sku_name       = "BC_Gen5_2"
  zone_redundant = true

  tags = {
    tag = var.exampletag
  }
}

resource "azurerm_mssql_failover_group" "gwa_sql_failover" {
  name      = "gwa-sql-failover-${var.env_name}"
  server_id = azurerm_mssql_server.gwa_sql_server["cc"].id
  databases = [
    azurerm_mssql_database.gwa_sql_database.id
  ]

  partner_server {
    id = azurerm_mssql_server.gwa_sql_server["eus2"].id
  }

  read_write_endpoint_failover_policy {
    mode          = "Automatic"
    grace_minutes = 80
  }

  tags = {
    tag = var.exampletag
  }
}