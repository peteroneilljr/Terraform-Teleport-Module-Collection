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


resource "null_resource" "teleport_grant_iam" {
  for_each = toset(var.rds_users)

  triggers = {
    resource_id = module.rds_postgresql.db_instance_resource_id
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = module.teleport_agent_rds.teleport_agent_public_ip
      private_key = var.private_key_file
    }
    inline = [
      "echo 'export PGUSER=\"${module.rds_postgresql.db_instance_username}\"' > ./postgres",
      "echo 'export PGPASSWORD=\"${random_password.rds.result}\"' >> ./postgres",
      "echo 'export PGHOST=\"${module.rds_postgresql.db_instance_address}\"' >> ./postgres",
      "echo 'export PGPORT=\"${module.rds_postgresql.db_instance_port}\"' >> ./postgres",
      "echo 'export PGDATABASE=\"${module.rds_postgresql.db_instance_name}\"' >> ./postgres",
    ]
  }

  provisioner "remote-exec" {

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = module.teleport_agent_rds.teleport_agent_public_ip
      private_key = var.private_key_file
    }
    inline = [
      "source ./postgres",
      "echo 'granting rds_iam to ${each.key}'",
      "psql -c 'CREATE USER ${each.key}; GRANT rds_iam TO ${each.key};'"
    ]
  }
}
