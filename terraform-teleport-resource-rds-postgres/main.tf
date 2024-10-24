resource "random_password" "rds" {
  length           = 22
  special          = true
  override_special = "."
}
locals {
  db_password = random_password.rds.result
}


module "rds_postgresql" {
  source = "terraform-aws-modules/rds/aws"

  identifier = lower(var.prefix)

  engine                   = "postgres"
  engine_version           = "14"
  engine_lifecycle_support = "open-source-rds-extended-support-disabled"
  family                   = "postgres14" # DB parameter group
  major_engine_version     = "14"         # DB option group

  instance_class        = "db.t4g.micro"
  allocated_storage     = 5
  max_allocated_storage = 10

  db_name  = "peterdemodb"
  username = "peter"
  port     = "5432"
  password = local.db_password

  manage_master_user_password         = false
  iam_database_authentication_enabled = true

  vpc_security_group_ids = [
    var.aws_security_group_id,
  ]

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = var.aws_subnet_ids

  # Database Deletion Protection
  deletion_protection = false
  skip_final_snapshot = true

}

module "rds_teleport" {
  source = "../terraform-teleport-agent"

  cloud = "AWS"

  aws_vpc_id            = var.aws_vpc_id
  aws_security_group_id = var.aws_security_group_id
  aws_subnet_id         = var.aws_subnet_ids[0]

  aws_key_pair         = var.aws_key_name
  aws_instance_profile = aws_iam_instance_profile.rds_postgresql.name


  agent_nodename = "rds-agent"

  teleport_proxy_address = var.teleport_proxy_address
  teleport_version       = var.teleport_version
  teleport_ssh_labels = {
    "type" = "agent"
  }

  teleport_agent_roles = ["Db"]

  teleport_rds_hosts = local.rds_hosts

}

locals {
  rds_hosts = {
    "db-dev1" = {
      "env"      = "dev"
      "endpoint" = module.rds_postgresql.db_instance_endpoint
      "address"  = module.rds_postgresql.db_instance_address
      "admin"    = module.rds_postgresql.db_instance_username
      "users"    = ["developer", "reader"]
      "database" = module.rds_postgresql.db_instance_name
      "password" = local.db_password
    }
    "db-dev2" = {
      "env"      = "dev"
      "endpoint" = module.rds_postgresql.db_instance_endpoint
      "address"  = module.rds_postgresql.db_instance_address
      "admin"    = module.rds_postgresql.db_instance_username
      "users"    = ["developer", "reader"]
      "database" = module.rds_postgresql.db_instance_name
      "password" = local.db_password
    }
    "db-production" = {
      "env"      = "prod"
      "endpoint" = module.rds_postgresql.db_instance_endpoint
      "address"  = module.rds_postgresql.db_instance_address
      "admin"    = module.rds_postgresql.db_instance_username
      "users"    = ["developer", "reader"]
      "database" = module.rds_postgresql.db_instance_name
      "password" = local.db_password
    }
  }
}

# ---------------------------------------------------------------------------- #
# Output psql settings
# ---------------------------------------------------------------------------- #

# output "psql" {
#   value     = <<EOF
#   export PGHOST='${module.rds_postgresql.db_instance_address}'
#   export PGPORT='5432'
#   export PGUSER='${module.rds_postgresql.db_instance_username}'
#   export PGPASSWORD='${random_password.rds.result}'
#   export PGDATABASE='${module.rds_postgresql.db_instance_name}'
#   EOF
#   sensitive = true
# }


# ---------------------------------------------------------------------------- #
# IAM RDS Role
# ---------------------------------------------------------------------------- #

resource "aws_iam_instance_profile" "rds_postgresql" {
  name  = "${var.prefix}RdsProfile"
  role  = aws_iam_role.rds_postgresql.name
}
resource "aws_iam_role" "rds_postgresql" {
  name  = "${var.prefix}RdsAssume"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "rds_postgresql" {
  name  = "${var.prefix}RdsPolicy"
  role  = aws_iam_role.rds_postgresql.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sts:AssumeRole",
        "rds:DescribeDBInstances",
        "rds:DescribeDBClusters",
        "rds:ModifyDBInstance",
        "rds:ModifyDBCluster",
        "rds-db:connect"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}