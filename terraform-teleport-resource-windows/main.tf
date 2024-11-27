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
  key_name               = var.aws_key_pair
  vpc_security_group_ids = [var.aws_security_group_id]
  subnet_id              = var.aws_subnet_id

  user_data_replace_on_change = true
  user_data = templatefile("${path.module}/config/windows.tftpl", {
    Users    = ["yoko", "peter"]
    Password = random_password.windows.result
    Version  = var.teleport_version
    Proxy    = "https://${var.teleport_proxy_address}"
    ComputerName = "teleport-${each.key}"
  })

  get_password_data = true

  ami                = data.aws_ami.windows.image_id
  ignore_ami_changes = true

  metadata_options = {
    http_endpoint : "enabled"
    http_tokens : "required"
  }

  tags = var.aws_tags

}

# ---------------------------------------------------------------------------- #
# Windows AMI Lookup
# ---------------------------------------------------------------------------- #
data "aws_ami" "windows" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base*"]
  }

  filter {
    name   = "platform"
    values = ["windows"]
  }
}
