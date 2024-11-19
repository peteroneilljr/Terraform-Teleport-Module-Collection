output private_ip_address {
  value       = google_sql_database_instance.main.private_ip_address
}
output db_name {
  value       = google_sql_database_instance.main.name
}
output user_name {
  value       = google_sql_user.iam_service_account_user.name
}
output service_account_email {
  value       = google_service_account.teleport_db_service.email
}
