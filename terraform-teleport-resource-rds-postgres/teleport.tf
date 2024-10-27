
module "rds_teleport" {
  source = "../terraform-teleport-agent"

  aws_vpc_id            = var.aws_vpc_id
  aws_security_group_id = var.aws_security_group_id
  aws_subnet_id         = var.aws_subnet_ids[0]

  public_ip = false

  aws_key_pair         = var.aws_key_name
  aws_instance_profile = aws_iam_instance_profile.rds_postgresql.name

  aws_tags = var.aws_tags


  agent_nodename = "rds-agent"

  teleport_proxy_address = var.teleport_proxy_address
  teleport_version       = var.teleport_version
  teleport_ssh_labels = {
    "type" = "agent"
  }

  teleport_agent_roles = ["Db"]

  teleport_rds_hosts = {
    "db-dev1" = {
      "env"      = "dev"
      "endpoint" = module.rds_postgresql.db_instance_endpoint
    }
    "db-dev2" = {
      "env"      = "dev"
      "endpoint" = module.rds_postgresql.db_instance_endpoint
    }
    "db-production" = {
      "env"      = "prod"
      "endpoint" = module.rds_postgresql.db_instance_endpoint
    }
  }
}
