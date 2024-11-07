# ---------------------------------------------------------------------------- #
# Deploy Teleport Agent 
# ---------------------------------------------------------------------------- #
module "teleport_agent" {
  source = "git::https://github.com/peteroneilljr/terraform-teleport-agent.git"

  count = var.teleport_agent_create ? 1 : 0

  aws_vpc_id            = var.aws_vpc_id
  aws_security_group_id = var.aws_security_group_id
  aws_subnet_id         = var.aws_subnet_id

  teleport_agent_roles = ["Node", "App"]

  teleport_cdn_address = var.teleport_cdn_address
  teleport_version     = var.teleport_version
  teleport_edition     = var.teleport_edition

  teleport_proxy_address = var.teleport_proxy_address

  teleport_node_enable = true
  teleport_node_name   = "${var.prefix}-agent"
  teleport_node_labels = {
    "type" = "agent"
  }

  aws_tags = var.aws_tags

  aws_key_pair         = var.aws_key_pair
  aws_instance_profile = aws_iam_instance_profile.console_access.name


  teleport_apps = var.teleport_apps
}
