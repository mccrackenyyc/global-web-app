resource "azurerm_resource_group" "gwa_sql_rg" {
  for_each = local.regions
  name     = "gwa-sql-rg-${each.key}-${var.env_name}"
  location = each.value.longform

  tags = {
    tag = var.exampletag
  }
}

resource "azurerm_storage_account" "gwa_sql_logs" {
  #checkov:skip=CKV_AZURE_43:False positive, storage account name is fine
  #checkov:skip=CKV2_AZURE_1:Azure managed key confirmed acceptable
  #checkov:skip=CKV2_AZURE_18:Azure managed key confirmed acceptable
  #checkov:skip=CKV_AZURE_190:Not supported in latest provider, set public_network_access_enabled argument instead
  for_each                      = local.regions
  name                          = "gwasqllogs${each.key}${var.env_name}"
  resource_group_name           = azurerm_resource_group.gwa_sql_rg[each.key].name
  location                      = azurerm_resource_group.gwa_sql_rg[each.key].location
  account_tier                  = "Standard"
  account_replication_type      = "GRS"
  min_tls_version               = "TLS1_2"
  public_network_access_enabled = false

  queue_properties {
    logging {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
      retention_policy_days = 100
    }
  }

  tags = {
    tag = var.exampletag
  }
}

resource "azurerm_mssql_server" "gwa_sql_server" {
  #checkov:skip=CKV_AZURE_23:Configuration not available in resource
  #checkov:skip=CKV_AZURE_24:Configuration not available in resource
  for_each                      = local.regions
  name                          = "gwa-sql-server-${each.key}-${var.env_name}"
  resource_group_name           = azurerm_resource_group.gwa_sql_rg[each.key].name
  location                      = azurerm_resource_group.gwa_sql_rg[each.key].location
  version                       = "12.0"
  public_network_access_enabled = false
  minimum_tls_version           = "1.2"

  azuread_administrator {
    azuread_authentication_only = true
    login_username              = var.admin_upn
    object_id                   = data.azuread_user.admin.object_id
  }

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