# ---------------------------------------------------------------------------- #
# Create a password for Windows machine
# ---------------------------------------------------------------------------- #
resource "random_password" "windows" {
  length = 40
}
# ---------------------------------------------------------------------------- #
# Create windows AWS Instances
# ---------------------------------------------------------------------------- #
module "windows_instances" {
  source = "terraform-aws-modules/ec2-instance/aws"

  for_each = toset(var.windows_machines)

  name = "teleport-${each.key}"

  instance_type          = "t3.small"
  key_name               = var.aws_key_name
  vpc_security_group_ids = [var.aws_security_group_id]
  subnet_id              = var.aws_subnet_id

  user_data_replace_on_change = true
  user_data = templatefile("${path.module}/config/windows.tftpl", {
    User     = "yoko"
    Password = random_password.windows.result
    Version  = var.teleport_version
    Proxy    = "https://${var.teleport_proxy_address}"
  })

  get_password_data = true

  ami                = var.aws_ami_windows
  ignore_ami_changes = true

  metadata_options = {
    http_endpoint : "enabled"
    http_tokens : "required"
  }

  tags = var.aws_tags

}
# ---------------------------------------------------------------------------- #
# Create Teleport Agent to proxy windows machines
# ---------------------------------------------------------------------------- #
module "windows_teleport" {
  source = "../terraform-teleport-agent"

  aws_vpc_id            = var.aws_vpc_id
  aws_security_group_id = var.aws_security_group_id
  aws_subnet_id         = var.aws_subnet_id

  aws_key_pair = var.aws_key_name
  aws_tags = var.aws_tags

  teleport_agent_roles = ["Node", "WindowsDesktop"]

  teleport_nodename = "windows-agent"

  teleport_proxy_address = var.teleport_proxy_address
  teleport_version       = var.teleport_version
  teleport_ssh_labels = {
    "type" = "agent"
  }

  teleport_windows_hosts = {
    for index, host in var.windows_machines: 
    host => {
      "addr" = module.windows_instances["${host}"].private_ip
      "labels" = {
        "env"  = "${host}"
      }
    }
  }
}