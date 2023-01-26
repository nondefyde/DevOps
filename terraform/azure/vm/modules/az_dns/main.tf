resource "azurerm_dns_zone" "vm_dns_zone" {
  name                = var.dns_domain
  resource_group_name = "${var.prefix}-group"
}

resource "azurerm_dns_a_record" "vm_dns_record" {
  name                = "*"
  zone_name           = azurerm_dns_zone.vm_dns_zone.name
  resource_group_name = "${var.prefix}-group"
  ttl                 = 300
  target_resource_id  = var.public_ip
}