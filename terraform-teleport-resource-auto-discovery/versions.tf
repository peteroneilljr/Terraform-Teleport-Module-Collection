terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.71"
    }
    teleport = {
      version = ">16.4.0"
      source  = "terraform.releases.teleport.dev/gravitational/teleport"
    }
  }
}