# ---------------------------------------------------------------------------- #
# Create Teleport Agent with Discovery Service Running
# ---------------------------------------------------------------------------- #
module "auto_discovery_agent" {
  source = "git::https://github.com/peteroneilljr/terraform-teleport-agent.git"

  aws_vpc_id            = var.aws_vpc_id
  aws_security_group_id = var.aws_security_group_id
  aws_subnet_id         = var.aws_subnet_id

  teleport_nodename = "discovery-agent"

  teleport_agent_roles = ["Node", "Discovery"]

  teleport_discovery_groups = {
    aws = {
      type              = "ec2"
      region            = "us-west-2"
      token_name        = teleport_provision_token.discovery_token.metadata.name
      ssm_document_name = aws_ssm_document.auto_discovery.name
      tags              = {
      "discovery" = "ec2"
      }
    }
  }

  teleport_proxy_address         = var.teleport_proxy_address
  teleport_version               = var.teleport_version
  teleport_ssh_labels = {
    "type" = "agent"
  }
  aws_key_pair         = var.aws_key_name
  aws_instance_profile = aws_iam_instance_profile.auto_discovery.name


}