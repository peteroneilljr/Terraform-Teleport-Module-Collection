resource "random_password" "rds" {
  length           = 22
  special          = true
  override_special = "."
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

  db_name  = "sedemodb"
  username = "teleport"
  port     = "5432"
  password = random_password.rds.result

  manage_master_user_password         = false
  iam_database_authentication_enabled = true

  # pubilcally accessible to create users and grants
  publicly_accessible = true


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
