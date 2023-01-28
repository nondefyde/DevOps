terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}

provider "cloudflare" {
  api_token = "<>"
}

variable "zone_id" {
  default = "<>"
}

variable "domain" {
  default = "<>"
}

resource "cloudflare_record" "a" {
  zone_id         = var.zone_id
  name            = "testing"
  value           = "192.64.119.41"
  type            = "A"
  proxied         = true
  allow_overwrite = true
  comment         = "Adding a testing record"
}

#parkingpage.namecheap.com