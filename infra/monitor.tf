resource "azurerm_monitor_action_group" "gwa_monitor_group_main" {
  name                = "gwa-monitor-action-group-main-${var.env_name}"
  resource_group_name = azurerm_resource_group.gwa_sql_rg[element(keys(local.regions), 0)].name
  short_name          = "monitor-${var.env_name}"

  email_receiver {
    name          = "monitor-email"
    email_address = "smccracken@live.ca"
  }
}

resource "azurerm_monitor_metric_alert" "gwa_data_space_percentage_usage_on_sql_database" {
  name                = "gwa-data-space-percentage-usage-on-sql-database-${var.env_name}"
  resource_group_name = azurerm_resource_group.gwa_sql_rg[element(keys(local.regions), 0)].name
  scopes              = [azurerm_mssql_database.gwa_sql_database.id]
  severity            = 1
  description         = "Action will be triggered when space utilization reaches 75%, only monitoring primary database since it's the write-heavy database"

  criteria {
    metric_namespace = "microsoft.sql/servers/databases"
    metric_name      = "storage_percent"
    aggregation      = "Maximum"
    operator         = "GreaterThan"
    threshold        = 75
  }

  action {
    action_group_id = azurerm_monitor_action_group.gwa_monitor_group_main.id
  }
}

resource "azurerm_monitor_metric_alert" "gwa_cpu_time_on_app_service" {
  for_each            = local.regions
  name                = "gwa-cpu-time-on-app-service-${each.key}-${var.env_name}"
  resource_group_name = azurerm_resource_group.gwa_web_rg[each.key].name
  scopes              = [azurerm_linux_web_app.gwa_linux_web_app[each.key].id]
  severity            = 2
  description         = "Dynamic alerts for higher than expected CPU time on linuxwebapp service"

  dynamic_criteria {
    metric_namespace  = "microsoft.web/sites"
    metric_name       = "CpuTime"
    aggregation       = "Maximum"
    operator          = "GreaterThan"
    alert_sensitivity = "Medium"
  }

  action {
    action_group_id = azurerm_monitor_action_group.gwa_monitor_group_main.id
  }
}