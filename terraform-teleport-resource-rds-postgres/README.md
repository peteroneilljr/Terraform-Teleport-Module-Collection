# RDS Postgres Module


```hcl
# ---------------------------------------------------------------------------- #
# Create RDS Instance 
# ---------------------------------------------------------------------------- #

module "terraform-teleport-rds" {
  source                = "git::https://github.com/peteroneilljr/Terraform-Teleport-Module-Collection.git//terraform-teleport-resource-rds-postgres"
  prefix                = local.prefix
  aws_vpc_id            = module.vpc.vpc_id
  aws_security_group_id = module.vpc.default_security_group_id
  aws_key_name          = aws_key_pair.peter.id
  aws_subnet_ids        = module.vpc.database_subnets
  aws_tags = {
    "purpose"              = "rds"
  }

  teleport_proxy_address = var.teleport_proxy_address
  teleport_version       = var.teleport_version
}

# ---------------------------------------------------------------------------- #
# Create Users
# ---------------------------------------------------------------------------- #
locals {
  rds_users                  = ["peter", "alice", "yoko"]
}

provider "postgresql" {
  host            = module.terraform-teleport-rds.host
  port            = module.terraform-teleport-rds.port
  database        = module.terraform-teleport-rds.database
  username        = module.terraform-teleport-rds.username
  password        = module.terraform-teleport-rds.password
  sslmode         = "require"
  connect_timeout = 30

  superuser = false
}
resource "postgresql_role" "db_user" {
  count = length(local.rds_users)
  name  = local.rds_users[count.index]
  login = true
  roles = ["rds_iam"]
}
```