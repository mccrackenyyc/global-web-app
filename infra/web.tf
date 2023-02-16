resource "azurerm_resource_group" "gwa_web_rg" {
  for_each = local.regions
  name     = "gwa-web-rg-${each.key}-${var.env_name}"
  location = each.value.longform

  tags = {
    tag = var.exampletag
  }
}

resource "azurerm_service_plan" "gwa_service_plan" {
  for_each            = local.regions
  name                = "gwa-service-plan-${each.key}-${var.env_name}"
  resource_group_name = azurerm_resource_group.gwa_web_rg[each.key].name
  location            = azurerm_resource_group.gwa_web_rg[each.key].location
  os_type             = "Linux"
  sku_name            = "P1v2"

  tags = {
    tag = var.exampletag
  }
}

resource "azurerm_linux_web_app" "gwa_linux_web_app" {
  for_each            = local.regions
  name                = "gwa-linux-web-app-${each.key}-${var.env_name}"
  resource_group_name = azurerm_resource_group.gwa_web_rg[each.key].name
  location            = azurerm_service_plan.gwa_service_plan[each.key].location
  service_plan_id     = azurerm_service_plan.gwa_service_plan[each.key].id

  site_config {}

  tags = {
    tag = var.exampletag
  }
}