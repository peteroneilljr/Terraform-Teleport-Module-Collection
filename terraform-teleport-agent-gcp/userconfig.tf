locals {
  agent_token = teleport_provision_token.teleport_agent.metadata.name
  commands = {
    shell = "#!/bin/bash"
    # ---------------------------------------------------------------------------- #
    usershell = <<-SETSHELL
      echo "# ---------------------------------------------------------------------------- #"
      echo "# Set bash as default shell "
      echo "# ---------------------------------------------------------------------------- #"

      sed -i 's|^SHELL=/bin/sh|SHELL=/bin/bash|' /etc/default/useradd
      SETSHELL
    # ---------------------------------------------------------------------------- #
    token = <<-TOKEN
      echo "# ---------------------------------------------------------------------------- #"
      echo "# Add Teleport Provision Token for Registration"
      echo "# ---------------------------------------------------------------------------- #"

      echo ${local.agent_token} > /tmp/token
      TOKEN
    # ---------------------------------------------------------------------------- #
    hostname = <<-SET_HOSTNAME
      echo "# ---------------------------------------------------------------------------- #"
      echo "# Match hostname to Teleport Resource Name"
      echo "# ---------------------------------------------------------------------------- #"

      hostname ${var.teleport_nodename}
      SET_HOSTNAME
    # ---------------------------------------------------------------------------- #
    systemctl = <<-SYSTEMCTL
      echo "# ---------------------------------------------------------------------------- #"
      echo "# Start Teleport Service"
      echo "# ---------------------------------------------------------------------------- #"

      systemctl enable teleport;
      systemctl restart teleport;
      sleep 2;
      systemctl status teleport;
      SYSTEMCTL
  }
  # ---------------------------------------------------------------------------- #
  install = {
    teleport = <<-INSTALL
      echo "# ---------------------------------------------------------------------------- #"
      echo "# Install Teleport"
      echo "# ---------------------------------------------------------------------------- #"

      TELEPORT_EDITION="cloud"
      TELEPORT_DOMAIN="${var.teleport_proxy_address}"
      TELEPORT_VERSION="$(curl https://$TELEPORT_DOMAIN/v1/webapi/automaticupgrades/channel/stable/cloud/version | sed 's/v//')"
      curl "https://cdn.teleport.dev/install-v$TELEPORT_VERSION.sh" | bash -s $TELEPORT_VERSION $TELEPORT_EDITION
      INSTALL
  # ---------------------------------------------------------------------------- #
  }
  resources = {
    start = <<-CONFIG_START
echo "# ---------------------------------------------------------------------------- #"
echo "# Configure Teleport"
echo "# ---------------------------------------------------------------------------- #"

cat<<-EOF >/etc/teleport.yaml
version: v3
teleport:
  nodename: ${var.teleport_nodename}
  auth_token: /tmp/token
  proxy_server: ${var.teleport_proxy_address}:443
  data_dir: /var/lib/teleport
  log:
    output: stderr
    severity: INFO
    format:
      output: json
CONFIG_START
    # ---------------------------------------------------------------------------- #
    ssh = <<-SSH
ssh_service:
  enabled: true
  pam:
    enabled: true
  labels:
%{for key, value in var.teleport_ssh_labels~}
    ${key}: ${value}
%{endfor~}
  enhanced_recording:
    enabled: ${var.teleport_enhanced_recording}
  commands:
  - name: kernel
    command: ['uname', '-r']
    period: 1h0m0s
  - name: "os"
    command: ["/usr/bin/uname"]
    period: 1h0m0s
SSH
    # ---------------------------------------------------------------------------- #
    proxy = <<-PROXY
proxy_service:
  enabled: false
auth_service:
  enabled: false
PROXY
    # ---------------------------------------------------------------------------- #
    gcp = <<-GCP_CONFIG
app_service:
  enabled: "yes"
  apps:
%{ for name, config in var.teleport_gcp_apps ~}
  - name: ${name}
    cloud: GCP
    labels:
%{ for key, value in config.labels ~}
      ${key}: ${value}
%{ endfor ~}
%{ endfor ~}
GCP_CONFIG
    # ---------------------------------------------------------------------------- #
    gcp_db = <<-GCP_DB
db_service:
  enabled: "yes"
  resources:
  - labels:
      "*": "*"
GCP_DB
    # ---------------------------------------------------------------------------- #
    end = <<-CONFIG_END
EOF
CONFIG_END
  }
}