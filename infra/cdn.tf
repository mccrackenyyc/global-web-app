resource "azurerm_resource_group" "gwa_cdn_rg" {
  name     = "gwa-cdn-rg-${var.env_name}"
  location = var.location

  tags = {
    tag = var.exampletag
  }
}

resource "azurerm_cdn_frontdoor_profile" "gwa_cdn_fd_profile" {
  name                = "gwa-cdn-fd-profile-${var.env_name}"
  resource_group_name = azurerm_resource_group.gwa_cdn_rg.name
  sku_name            = "Standard_AzureFrontDoor"

  tags = {
    tag = var.exampletag
  }
}

resource "azurerm_cdn_frontdoor_origin_group" "gwa_cdn_fd_origin_group" {
  name                     = "gwa-cdn-fd-origin-group-${var.env_name}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.gwa_cdn_fd_profile.id
  session_affinity_enabled = true

  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 10

  health_probe {
    interval_in_seconds = 240
    path                = "/healthProbe"
    protocol            = "Https"
    request_type        = "HEAD"
  }

  load_balancing {
    additional_latency_in_milliseconds = 0
    sample_size                        = 16
    successful_samples_required        = 3
  }
}

resource "azurerm_cdn_frontdoor_origin" "gwa_cdn_fd_origin" {
  for_each                      = local.regions
  name                          = "gwa-cdn-fd-origin-${each.key}-${var.env_name}"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.gwa_cdn_fd_origin_group.id
  enabled                       = true

  certificate_name_check_enabled = false

  host_name          = azurerm_linux_web_app.gwa_linux_web_app[each.key].default_hostname
  http_port          = 80
  https_port         = 443
  origin_host_header = var.website_hostname
  priority           = 1
  weight             = 1
}