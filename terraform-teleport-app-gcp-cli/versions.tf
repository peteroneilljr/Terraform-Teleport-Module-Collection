terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.6"
    }
    teleport = {
      version = ">16.4.0"
      source  = "terraform.releases.teleport.dev/gravitational/teleport"
    }
  }
}