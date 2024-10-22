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


# ---------------------------------------------------------------------------- #
# Deploy Teleport Agent 
# ---------------------------------------------------------------------------- #
module "teleport_gcp" {
  source = "../terraform-teleport-node"

  # create = local.teleport.gcp

  cloud  = "GCP"
  prefix = var.prefix

  teleport_proxy_address = var.teleport_proxy_address
  teleport_version       = var.teleport_version
  teleport_ssh_labels = {
    "type" = "agent"
  }
  teleport_agent_roles = ["App"]

  agent_nodename = "gcp-agent"

  gcp_service_account_email = google_service_account.teleport_cli.email
  gcp_machine_type          = "e2-micro"
  gcp_region                = var.gcp_region
  teleport_gcp_apps = {
    "google-cloud-cli" = {
      "labels" = {
        "cloud" = "gcp"
      }
    }
  }
}
