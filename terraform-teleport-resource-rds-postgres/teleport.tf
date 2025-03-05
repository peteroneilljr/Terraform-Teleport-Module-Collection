module "teleport_agent_rds" {
  # source = "git::https://github.com/peteroneilljr/terraform-teleport-agent.git"
  source = "../terraform-teleport-agent"

  count = var.teleport_agent_enable ? 1:0

  aws_vpc_id            = var.aws_vpc_id
  aws_security_group_id = var.aws_security_group_id
  aws_subnet_id         = var.aws_subnet_ids[0]

  public_ip = true

  teleport_agent_roles = ["Node", "Db"]

  teleport_proxy_address = var.teleport_proxy_address

  aws_key_pair         = var.aws_key_pair
  aws_instance_profile = aws_iam_instance_profile.rds_postgresql.name

  aws_tags = var.aws_tags

  teleport_node_name = "rds-agent"
  teleport_node_labels = {
    "type" = "agent"
  }

  teleport_agent_packages = ["postgresql15", "postgresql15-server"]

  teleport_databases = {
    "db-dev1" = {
      "uri"         = module.rds_postgresql.db_instance_endpoint
      "protocol"    = "postgres"
      "description" = "postgres"
      "labels" = {
        "env" = "dev"
      }
      "admin_user" = {
        "name" = "teleport-admin"
      }
    }
    "db-dev2" = {
      "uri"         = module.rds_postgresql.db_instance_endpoint
      "protocol"    = "postgres"
      "description" = "postgres"
      "labels" = {
        "env" = "dev"
      }
      "admin_user" = {
        "name" = "teleport-admin"
      }
    }
    "db-production" = {
      "uri"         = module.rds_postgresql.db_instance_endpoint
      "protocol"    = "postgres"
      "description" = "postgres"
      "labels" = {
        "env" = "prod"
      }
      "admin_user" = {
        "name" = "teleport-admin"
      }
    }
  }
}
