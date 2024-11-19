# Google SQL on Teleport


```hcl
module "teleport-gcp-sql" {

  source = "./modules/terraform-teleport-gcp-sql"

  prefix                 = local.prefix
  gcp_project            = var.gcp_project
  gcp_region             = var.gcp_region
  teleport_user          = var.teleport_user
}
resource "teleport_database" "gpc_sql_postgres" {

  version = "v3"
  metadata = {
    name        = "gpc-sql-postgres"
    description = "GCP SQL database"
    labels = {
      "teleport.dev/origin" = "dynamic" 
      "cloud" = "gcp"
    }
  }

  spec = {
    protocol = "postgres"
    uri      = "${module.teleport-gcp-sql.private_ip_address}:5432"
    gcp = {
      instance_id = module.teleport-gcp-sql.db_name
      project_id  = var.gcp_project
    }
  }
}

module "teleport_gcp" {

  source = "./modules/terraform-teleport-agent-gcp"

  prefix = local.prefix

  gcp_machine_type          = "e2-micro"
  gcp_region                = var.gcp_region
  gcp_service_account_email = module.teleport-gcp-sql.service_account_email


  teleport_proxy_address = var.teleport_proxy_address
  teleport_version       = var.teleport_version
  teleport_ssh_labels = {
    "type" = "agent"
  }
  teleport_agent_roles = ["Node", "Db"]

  teleport_nodename = "gcp-db-agent"

}

# ---------------------------------------------------------------------------- #
# outputs
# ---------------------------------------------------------------------------- #
output gcp_db_user_name {
  value       = try(module.teleport-gcp-sql.user_name, "null")
}
```