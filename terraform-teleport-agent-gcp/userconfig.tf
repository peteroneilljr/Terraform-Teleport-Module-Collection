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
    hostname = <<-HOSTNAME
      echo "# ---------------------------------------------------------------------------- #"
      echo "# Match hostname to Teleport Resource Name"
      echo "# ---------------------------------------------------------------------------- #"

      hostname ${var.teleport_nodename}
      HOSTNAME
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
      curl ${var.teleport_cdn_address} | bash -s $TELEPORT_VERSION $TELEPORT_EDITION
      INSTALL
    # ---------------------------------------------------------------------------- #
    rds = <<-INSTALL_RDS
      echo "# ---------------------------------------------------------------------------- #"
      echo "# Install postgres on Amazon Linux"
      echo "# ---------------------------------------------------------------------------- #"

      dnf install postgresql15.x86_64 -y

      INSTALL_RDS
  }
  # ---------------------------------------------------------------------------- #
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
    rdp = <<-RDP
windows_desktop_service:
  enabled: yes
  static_hosts:
%{for name, host in var.teleport_windows_hosts~}
  - addr: ${host.addr}
    name: ${name}
    ad: false
    labels:
      env: ${host.env}
      cloud: aws
      os: windows
%{endfor~}
RDP
    # ---------------------------------------------------------------------------- #
    rds = <<-RDS
db_service:
  enabled: "yes"
  databases:
%{for name, host in var.teleport_rds_hosts~}
  - name: ${name}
    description: "postgres"
    protocol: "postgres"
    uri: "${host.endpoint}"
    static_labels:
      env: ${host.env}
%{endfor~}
RDS
    # ---------------------------------------------------------------------------- #
    aws = <<-AWS
app_service:
  enabled: "yes"
  apps:
  - name: awsconsole
    uri: "https://console.aws.amazon.com/"
    labels:
      cloud: aws
      env: dev
  - name: awsconsole-admin
    uri: "https://console.aws.amazon.com/"
    labels:
      cloud: aws
      env: prod
AWS
    # ---------------------------------------------------------------------------- #
    aws = <<-AWS_CONFIG
app_service:
  enabled: "yes"
  apps:
%{for name, config in var.teleport_aws_apps~}
  - name: ${name}
    uri: ${config.uri}
    cloud: AWS
    labels:
%{for key, value in config.labels~}
      ${key}: ${value}
%{endfor~}
%{endfor~}
AWS_CONFIG
    # ---------------------------------------------------------------------------- #
    gcp = <<-GCP_CONFIG
app_service:
  enabled: "yes"
  apps:
%{~for name, config in var.teleport_gcp_apps~}
  - name: ${name}
    cloud: GCP
    labels:
%{~for key, value in config.labels~}
      ${key}: ${value}
%{~endfor~}
%{~endfor~}
GCP_CONFIG
    # ---------------------------------------------------------------------------- #
    end = <<-CONFIG_END
EOF
CONFIG_END
  }
}