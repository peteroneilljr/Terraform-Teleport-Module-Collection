# https://goteleport.com/docs/enroll-resources/database-access/enroll-google-cloud-databases/postgres-cloudsql/

# ---------------------------------------------------------------------------- #
# Create Service Account for Teleport db_service
# ---------------------------------------------------------------------------- #
resource "google_service_account" "teleport_db_service" {
  account_id   = "${var.prefix}-teleport-db-service"
  display_name = "${var.prefix}-teleport-db-service"
  description  = "Service Account to view DBS"
}
resource "google_project_iam_binding" "teleport_db_service" {
  project = var.gcp_project
  role    = "roles/cloudsql.client"

  members = [
    google_service_account.teleport_db_service.member,
  ]
}

# ---------------------------------------------------------------------------- #
# Create a Service Account for Teleport User to acccess Database
# ---------------------------------------------------------------------------- #
resource "google_service_account" "teleport_db_user" {
  account_id   = "${var.prefix}-teleport-db-user"
  display_name = "${var.prefix}-teleport-db-user"
  description  = "user Account to view DBS"
}
resource "google_project_iam_binding" "teleport_db_user" {
  project = var.gcp_project
  role    = "roles/cloudsql.instanceUser"

  members = [
    google_service_account.teleport_db_user.member,
  ]
}

# ---------------------------------------------------------------------------- #
# The Teleport Database Service must be able to impersonate this service account.
# ---------------------------------------------------------------------------- #
resource "google_service_account_iam_binding" "teleport_impersonate" {
  service_account_id = google_service_account.teleport_db_user.name
  role               = "roles/iam.serviceAccountTokenCreator"

  members = [
    google_service_account.teleport_db_service.member,
  ]
}

# ---------------------------------------------------------------------------- #
# Create Google SQL Databse with Postgresql engine
# ---------------------------------------------------------------------------- #
data "google_compute_network" "default" {
  name = "default"
}
resource "google_sql_database_instance" "main" {
  name             = "${var.prefix}-teleport-instance"
  database_version = "POSTGRES_15"
  region           = var.gcp_region

  deletion_protection = false

  settings {
    tier = "db-f1-micro"

    database_flags {
      # Teleport will use IAM Auth to access DB
      name  = "cloudsql.iam_authentication"
      value = "on"
    } 

    # Grant private ip on Default network
    ip_configuration {
      ipv4_enabled                                  = true
      private_network                               = data.google_compute_network.default.self_link
      # enable_private_path_for_google_cloud_services = true
    }

  }
}

# ---------------------------------------------------------------------------- #
# Create DB User
# ---------------------------------------------------------------------------- #
resource "google_sql_user" "iam_user" {
  name     = var.teleport_user
  instance = google_sql_database_instance.main.name
  type     = "CLOUD_IAM_USER"
}
resource "google_sql_user" "iam_service_account_user" {
  # Note: for Postgres only, GCP requires omitting the ".gserviceaccount.com" suffix
  # from the service account email due to length limits on database usernames.
  name     = trimsuffix(google_service_account.teleport_db_user.email, ".gserviceaccount.com")
  instance = google_sql_database_instance.main.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
}

