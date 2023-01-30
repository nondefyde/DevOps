resource "azurerm_dns_zone" "vm_dns_zone" {
  name                = "dev.${var.dns_domain}"
  resource_group_name = "${var.prefix}-group"
}

resource "azurerm_dns_cname_record" "vm_dns_record" {
  name                = "*"
  zone_name           = azurerm_dns_zone.vm_dns_zone.name
  resource_group_name = "${var.prefix}-group"
  ttl                 = 300
  record              = var.public_ip_dns_name
  depends_on = [azurerm_dns_zone.vm_dns_zone]
}

resource "cloudflare_record" "cf_vm_www_record" {
  zone_id         = var.cloudflare_zone_id
  name            = "www"
  value           = var.dns_domain
  type            = "CNAME"
  proxied         = true
  allow_overwrite = true

  depends_on = [azurerm_dns_cname_record.vm_dns_record]
}

resource "cloudflare_record" "cf_vm_sub_domain_cname_record" {
  zone_id         = var.cloudflare_zone_id
  name            = "*.${var.service}"
  value           = var.public_ip_dns_name
  type            = "CNAME"
  allow_overwrite = true

  depends_on = [azurerm_dns_cname_record.vm_dns_record]
}

resource "cloudflare_record" "cf_vm_cname_record" {
  zone_id         = var.cloudflare_zone_id
  name            = "*"
  value           = var.public_ip_dns_name
  type            = "CNAME"
  proxied         = true
  allow_overwrite = true

  depends_on = [azurerm_dns_cname_record.vm_dns_record]
}

resource "cloudflare_record" "cf_vm_a_record" {
  zone_id         = var.cloudflare_zone_id
  name            = var.dns_domain
  value           = var.public_ip
  type            = "A"
  proxied         = true
  allow_overwrite = true

  depends_on =  [azurerm_dns_cname_record.vm_dns_record]
}
