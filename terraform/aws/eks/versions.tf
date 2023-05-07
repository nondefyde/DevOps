terraform {
  backend "s3" {}
  required_version = ">=1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.66.1"
    }
  }
}
