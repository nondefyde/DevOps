resource "cloudflare_record" "cf_gateway_url_cname_record" {
  zone_id         = var.cloudflare_zone_id
  name            = "api"
  value           = var.api_gateway
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
