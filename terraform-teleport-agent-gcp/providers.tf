terraform {
  required_providers {
    teleport = {
      version = ">16.0.0"
      source  = "terraform.releases.teleport.dev/gravitational/teleport"
    }
    random = {}
  }
}
