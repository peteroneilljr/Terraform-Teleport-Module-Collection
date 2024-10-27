
module "rds_teleport" {
  source = "git::https://github.com/peteroneilljr/terraform-teleport-agent.git"

  aws_vpc_id            = var.aws_vpc_id
  aws_security_group_id = var.aws_security_group_id
  aws_subnet_id         = var.aws_subnet_ids[0]

  public_ip = false

  aws_key_pair         = var.aws_key_name
  aws_instance_profile = aws_iam_instance_profile.rds_postgresql.name

  aws_tags = var.aws_tags


  teleport_nodename = "rds-agent"

  teleport_proxy_address = var.teleport_proxy_address
  teleport_version       = var.teleport_version
  teleport_ssh_labels = {
    "type" = "agent"
  }

  teleport_agent_roles = ["Node","Db"]

  teleport_databases = {
    "db-dev1" = {
      "uri" = module.rds_postgresql.db_instance_endpoint
      "protocol" = "postgres"
      "description" = "postgres"
      "labels" = {
        "env"      = "dev"
      }
    }
    "db-dev2" = {
      "uri" = module.rds_postgresql.db_instance_endpoint
      "protocol" = "postgres"
      "description" = "postgres"
      "labels" = {
        "env"      = "dev"
      }
    }
    "db-production" = {
      "uri" = module.rds_postgresql.db_instance_endpoint
      "protocol" = "postgres"
      "description" = "postgres"
      "labels" = {
        "env"      = "prod"
      }
    }
  }
}
