output "dns_cname_record" {
  value     = cloudflare_record.cf_vm_subdomain_cname_record
}

output "cf_vm_ssl_record" {
  value     = cloudflare_certificate_pack.cf_vm_ssl_record.hosts
}
