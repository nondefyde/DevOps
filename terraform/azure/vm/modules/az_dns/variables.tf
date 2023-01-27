variable "prefix" {
  type        = string
  description = "The prefix for deployment"
}

variable "public_ip" {
  type        = string
  description = "Azure Resource Manager Subscription ID"
}

variable "public_ip_dns_name" {
  type        = string
  description = "public dns for cname"
}

variable "dns_domain" {
  type = string
  description = "DNS domain"
}

variable "cloudflare_zone_id" {
  type = string
  description = "Cloudflare zone id"
}