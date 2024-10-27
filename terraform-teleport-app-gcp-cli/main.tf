resource "google_service_account" "teleport_cli" {
  # controlling service account for the Application Service
  account_id   = "${var.prefix}-teleport-google-cloud-cli"
  display_name = "${var.prefix}-teleport-google-cloud-cli"
  description  = "Google Cloud CLI access"
}
resource "google_service_account" "teleport_vm_viewer" {
  # can view vms
  account_id   = "${var.prefix}-teleport-vm-viewer"
  display_name = "${var.prefix}-teleport-vm-viewer"
  description  = "Sample service account to demonstrate Teleport"
}

resource "google_project_iam_binding" "teleport_vm_viewer" {
  project = var.gcp_project
  role    = "roles/compute.viewer"

  members = [
    google_service_account.teleport_vm_viewer.member,
  ]
}

resource "google_service_account_iam_binding" "teleport_vm_viewer" {
  # main CLI service account can impersonate vm viewer
  service_account_id = google_service_account.teleport_vm_viewer.name
  role               = "roles/iam.serviceAccountTokenCreator"

  members = [
    google_service_account.teleport_cli.member,
  ]
}
