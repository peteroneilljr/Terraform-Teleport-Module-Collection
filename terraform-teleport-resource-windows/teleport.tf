# ---------------------------------------------------------------------------- #
# Create Teleport Agent to proxy windows machines
# ---------------------------------------------------------------------------- #
module "windows_teleport" {
  source = "git::https://github.com/peteroneilljr/terraform-teleport-agent.git"

  aws_vpc_id            = var.aws_vpc_id
  aws_security_group_id = var.aws_security_group_id
  aws_subnet_id         = var.aws_subnet_id

  aws_key_pair = var.aws_key_pair
  aws_tags = var.aws_tags

  teleport_agent_roles = ["Node", "WindowsDesktop"]

  teleport_node_name = "windows-agent"
  teleport_node_labels = {
    "type" = "agent"
  }
  
  teleport_proxy_address = var.teleport_proxy_address
  teleport_version       = var.teleport_version


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