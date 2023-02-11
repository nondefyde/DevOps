resource "cloudflare_record" "cf_vm_subdomain_cname_record" {
  zone_id         = var.cloudflare_zone_id
  name            = "*.${var.service}"
  value           = var.public_ip_dns_name
  type            = "CNAME"
  proxied         = true
  allow_overwrite = true
}

resource "cloudflare_certificate_pack" "cf_vm_ssl_record" {
  zone_id               = var.cloudflare_zone_id
  type                  = "advanced"
  hosts                 = [var.dns_domain, "*.${var.dns_domain}", "*.${var.service}.${var.dns_domain}"]
  validation_method     = "txt"
  validity_days         = 365
  certificate_authority = "digicert"
  cloudflare_branding   = false
  wait_for_active_status = true
}