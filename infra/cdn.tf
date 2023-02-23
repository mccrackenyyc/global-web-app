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
    path                = "/"
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
  for_each                       = local.regions
  name                           = "gwa-cdn-fd-origin-${each.key}-${var.env_name}"
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.gwa_cdn_fd_origin_group.id
  enabled                        = true
  certificate_name_check_enabled = false

  host_name          = azurerm_linux_web_app.gwa_linux_web_app[each.key].default_hostname
  http_port          = 80
  https_port         = 443
  origin_host_header = var.website_hostname
  priority           = 1
  weight             = 1
}

resource "azurerm_cdn_frontdoor_endpoint" "gwa_cdn_fd_endpoint" {
  name                     = "gwa-cdn-fd-endpoint-${var.env_name}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.gwa_cdn_fd_profile.id

  tags = {
    tag = var.exampletag
  }
}

resource "azurerm_cdn_frontdoor_custom_domain" "gwa_cdn_fd_custom_domain" {
  name                     = "gwa-cdn-fd-custom-domain-${var.env_name}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.gwa_cdn_fd_profile.id
  dns_zone_id              = azurerm_dns_zone.gwa_dnszone.id
  host_name                = azurerm_dns_zone.gwa_dnszone.name

  tls {
    certificate_type    = "ManagedCertificate"
    minimum_tls_version = "TLS12"
  }
}

resource "azurerm_cdn_frontdoor_route" "gwa_cdn_fd_route" {
  name                          = "gwa-cdn-fd-route-${var.env_name}"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.gwa_cdn_fd_endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.gwa_cdn_fd_origin_group.id
  cdn_frontdoor_origin_ids = [for key, value in local.regions :
  azurerm_cdn_frontdoor_origin.gwa_cdn_fd_origin[key].id]
  enabled = true

  forwarding_protocol    = "HttpsOnly"
  https_redirect_enabled = true
  patterns_to_match      = ["/*"]
  supported_protocols    = ["Http", "Https"]

  cdn_frontdoor_custom_domain_ids = [azurerm_cdn_frontdoor_custom_domain.gwa_cdn_fd_custom_domain.id]
  link_to_default_domain          = true

  cache {
    query_string_caching_behavior = "IgnoreSpecifiedQueryStrings"
    query_strings                 = ["account", "settings"]
    compression_enabled           = true
    content_types_to_compress     = ["text/html", "text/javascript", "text/xml"]
  }
}

resource "azurerm_cdn_frontdoor_custom_domain_association" "gwa_cdn_fd_custom_domain_association" {
  cdn_frontdoor_custom_domain_id = azurerm_cdn_frontdoor_custom_domain.gwa_cdn_fd_custom_domain.id
  cdn_frontdoor_route_ids        = [azurerm_cdn_frontdoor_route.gwa_cdn_fd_route.id]
}

resource "azurerm_dns_txt_record" "gwa_cdn_dns_verifytxtrecord" {
  name                = "_dnsauth"
  zone_name           = azurerm_dns_zone.gwa_dnszone.name
  resource_group_name = azurerm_resource_group.gwa_web_rg[element(keys(local.regions), 0)].name
  ttl                 = 3600

  record {
    value = azurerm_cdn_frontdoor_custom_domain.gwa_cdn_fd_custom_domain.validation_token
  }
}