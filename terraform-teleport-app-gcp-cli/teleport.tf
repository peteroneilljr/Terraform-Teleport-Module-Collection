
module "teleport_gcp" {
  source = "../terraform-teleport-agent-gcp"

  prefix = var.prefix
  
  gcp_service_account_email = google_service_account.teleport_cli.email
  gcp_machine_type          = "e2-micro"
  gcp_region                = var.gcp_region

  teleport_proxy_address = var.teleport_proxy_address
  teleport_version       = var.teleport_version
  teleport_ssh_labels = {
    "type" = "agent"
  }
  teleport_agent_roles = ["Node", "App"]

  teleport_nodename = "gcp-agent"

  teleport_gcp_apps = {
    "google-cloud-cli" = {
      "cloud" = "GCP"
      "labels" = {
        "env" = "dev"
      }
    }
  }
}
