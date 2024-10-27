resource "google_compute_instance" "teleport_agent" {
  name         = "${var.prefix}-${var.teleport_nodename}"
  machine_type = var.gcp_machine_type
  zone = "${var.gcp_region}-a"


  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }


  network_interface {
    network = "default"

    access_config {} # remove to make private
  }

  metadata_startup_script = local_file.teleport_config.content

  service_account {
    email  = var.gcp_service_account_email
    scopes = ["cloud-platform"]
  }
  lifecycle {
    ignore_changes = [
      metadata,
    ]
  }
}