# ---------------------------------------------------------------------------- #
# Create a password for Windows machine
# ---------------------------------------------------------------------------- #
resource "random_password" "windows" {
  count  = var.create ? 1 : 0
  length = 40
}
# ---------------------------------------------------------------------------- #
# Create windows AWS Instances
# ---------------------------------------------------------------------------- #
module "windows_instances" {
  source = "terraform-aws-modules/ec2-instance/aws"

  create = var.create

  for_each = toset([
    "dev",
    "prod",
  ])

  name = "teleport-${each.key}"

  instance_type          = "t3.small"
  key_name               = var.aws_key_name
  vpc_security_group_ids = [var.aws_security_group_id]
  subnet_id              = var.aws_subnet_id

  user_data_replace_on_change = true
  user_data = templatefile("${path.module}/config/windows.tftpl", {
    User     = "yoko"
    Password = try(random_password.windows[0].result, "")
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
}
# ---------------------------------------------------------------------------- #
# Create Teleport Agent to proxy windows machines
# ---------------------------------------------------------------------------- #
module "windows_teleport" {
  source = "../terraform-teleport-agent"

  create = var.create

  cloud = "AWS"

  aws_vpc_id            = var.aws_vpc_id
  aws_security_group_id = var.aws_security_group_id
  aws_subnet_id         = var.aws_subnet_id

  agent_nodename = "win-agent"

  teleport_proxy_address = var.teleport_proxy_address
  teleport_version       = var.teleport_version
  teleport_ssh_labels = {
    "type" = "agent"
  }

  teleport_agent_roles = ["WindowsDesktop"]

  teleport_windows_hosts = {
    "development" = {
      "env"  = "dev"
      "addr" = var.create ? module.windows_instances["dev"].private_ip : "1.1.1.1"
    }
    "production" = {
      "env"  = "prod"
      "addr" = var.create ? module.windows_instances["prod"].private_ip : "1.1.1.1"
    }
  }

  aws_key_pair = var.aws_key_name

}