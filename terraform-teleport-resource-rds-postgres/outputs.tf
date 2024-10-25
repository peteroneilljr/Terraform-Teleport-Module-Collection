output "psql" {
  value     = <<EOF
  export PGHOST='${module.rds_postgresql.db_instance_address}'
  export PGPORT='5432'
  export PGUSER='${module.rds_postgresql.db_instance_username}'
  export PGPASSWORD='${random_password.rds.result}'
  export PGDATABASE='${module.rds_postgresql.db_instance_name}'
  EOF
  sensitive = true
}
output host {
  value       = module.rds_postgresql.db_instance_address
  description = "description"
}
output port {
  value       = module.rds_postgresql.db_instance_port
  description = "description"
}
output username {
  value       = module.rds_postgresql.db_instance_username
  description = "description"
}
output database {
  value       = module.rds_postgresql.db_instance_name
  description = "description"
}
output password {
  value       = random_password.rds.result
  sensitive = true
  description = "description"
}
