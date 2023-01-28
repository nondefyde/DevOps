output "dns_a_record" {
  value     = cloudflare_record.cf_vm_cname_record.name
}

output "dns_cname_record" {
  value     = cloudflare_record.cf_vm_cname_record.name
}

output "dns_www_cname_record" {
  value     = cloudflare_record.cf_vm_www_record.name
}