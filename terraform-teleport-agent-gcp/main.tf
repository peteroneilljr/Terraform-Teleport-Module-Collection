resource "random_string" "teleport_agent" {
  length  = 32
  special = false
}
resource "teleport_provision_token" "teleport_agent" {
  version = "v2"
  spec = {
    roles = var.teleport_agent_roles
  }
  metadata = {
    name    = random_string.teleport_agent.result
    expires = timeadd(timestamp(), "4h")

    labels = {
      "teleport.dev/origin" = "dynamic"
    }
  }
  lifecycle {
    ignore_changes = [
      metadata.expires,
    ]
  }
}

resource "local_file" "teleport_config" {
  filename = "${path.module}/configs/${var.teleport_nodename}-teleport.conf"

  content = <<-EOF
  ${local.commands.shell}
  ${local.commands.usershell}
  ${local.commands.token}
  ${local.commands.hostname}
  ${local.install.teleport}
  ${local.resources.start}
  ${local.resources.ssh}
  ${length(var.teleport_windows_hosts) > 0 ? local.resources.rdp : ""}
  ${length(var.teleport_aws_apps) > 0 ? local.resources.aws : ""}
  ${length(var.teleport_gcp_apps) > 0 ? local.resources.gcp : ""}
  ${local.resources.proxy}
  ${local.resources.end}
  ${local.commands.systemctl}
  EOF
}
