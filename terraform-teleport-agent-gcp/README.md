# GCP Access

```hcl
module "terraform-teleport-gcp-cli" {
  source                 = "git::https://github.com/peteroneilljr/Terraform-Teleport-Module-Collection.git//terraform-teleport-app-gcp-cli"
  prefix                 = local.prefix
  gcp_project            = var.gcp_project
  gcp_region             = var.gcp_region
  teleport_proxy_address = var.teleport_proxy_address
  teleport_version       = var.teleport_version
}
```